import CryptoKit
import Foundation

struct ManifestExtractor {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()

    func normalizedURLString(from rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") || trimmed.hasPrefix("itms-services://") {
            return trimmed
        }
        return "http://\(trimmed)"
    }

    func isDirectIpaLink(_ url: URL) -> Bool {
        let absolute = url.absoluteString.lowercased()
        return absolute.hasSuffix(".ipa") || absolute.contains(".ipa?")
    }

    func isMobileProvisionLink(_ url: URL, patterns: [String]) -> Bool {
        let absolute = url.absoluteString.lowercased()
        return patterns.contains { pattern in
            let escaped = NSRegularExpression.escapedPattern(for: pattern.lowercased())
                .replacingOccurrences(of: "\\*", with: ".*")
            return absolute.range(of: "^\(escaped)$", options: .regularExpression) != nil
        }
    }

    func manifestURL(from url: URL) -> URL? {
        let absolute = url.absoluteString.removingPercentEncoding ?? url.absoluteString
        guard absolute.hasPrefix("itms-services://") || absolute.contains("itemService=") else {
            return nil
        }

        guard let components = URLComponents(string: absolute) else {
            return nil
        }

        let queryItems = components.queryItems ?? []
        let keys = ["url", "itemService"]

        for key in keys {
            if let value = queryItems.first(where: { $0.name == key })?.value,
               let manifestURL = URL(string: value.removingPercentEncoding ?? value) {
                return manifestURL
            }
        }

        return nil
    }

    func fetchManifestRecord(manifestURL: URL, sourcePageURL: String?) async throws -> IpaRecord {
        var request = URLRequest(url: manifestURL)
        request.setValue("com.apple.appstored/1.0 iOS/18.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ExtractionError.invalidResponse
        }

        guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            throw ExtractionError.invalidManifest
        }

        return try record(fromManifest: plist, sourcePageURL: sourcePageURL)
    }

    func makeDirectIpaRecord(from url: URL, sourcePageURL: String?) -> IpaRecord {
        let absolute = url.absoluteString
        let fileName = url.lastPathComponent.removingPercentEncoding ?? url.lastPathComponent
        let name = fileName.replacingOccurrences(of: ".ipa", with: "", options: [.caseInsensitive])

        return IpaRecord(
            id: stableID(for: "\(absolute)|\(sourcePageURL ?? "")"),
            title: name.isEmpty ? L10n.string("common.untitledApp") : name,
            version: nil,
            bundleIdentifier: nil,
            downloadURL: absolute,
            iconURL: nil,
            fromPageURL: sourcePageURL,
            createdAt: .now,
            localFileName: nil
        )
    }

    func stableID(for text: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(text.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    private func record(fromManifest plist: [String: Any], sourcePageURL: String?) throws -> IpaRecord {
        guard
            let items = plist["items"] as? [[String: Any]],
            let item = items.first,
            let metadata = item["metadata"] as? [String: Any]
        else {
            throw ExtractionError.invalidManifest
        }

        let assets = item["assets"] as? [[String: Any]] ?? []
        let packageURL = assets.first(where: { ($0["kind"] as? String) == "software-package" })?["url"] as? String
        let iconURL = assets.first(where: { ($0["kind"] as? String) == "display-image" })?["url"] as? String

        guard let packageURL, !packageURL.isEmpty else {
            throw ExtractionError.invalidManifest
        }

        let bundleIdentifier = metadata["bundle-identifier"] as? String
        let version = metadata["bundle-version"] as? String
        let title = (metadata["title"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? L10n.string("common.untitledApp")
        let id = stableID(for: "\(bundleIdentifier ?? "")|\(version ?? "")|\(sourcePageURL ?? packageURL)")

        return IpaRecord(
            id: id,
            title: title,
            version: version,
            bundleIdentifier: bundleIdentifier,
            downloadURL: packageURL,
            iconURL: iconURL,
            fromPageURL: sourcePageURL,
            createdAt: .now,
            localFileName: nil
        )
    }
}

enum ExtractionError: LocalizedError {
    case invalidManifest
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidManifest:
            L10n.string("extraction.error.invalidManifest")
        case .invalidResponse:
            L10n.string("extraction.error.invalidResponse")
        }
    }
}
