import Foundation

struct PersistenceController {
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let snapshotWriter = SnapshotWriter()

    init() {
        decoder.dateDecodingStrategy = .iso8601
    }

    private var rootDirectory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("IpaDownloadToolNative", isDirectory: true)
    }

    var downloadsDirectory: URL {
        rootDirectory.appendingPathComponent("Downloads", isDirectory: true)
    }

    private var stateURL: URL {
        rootDirectory.appendingPathComponent("State.json")
    }

    func prepareDirectories() throws {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    func loadSnapshot() -> AppSnapshot {
        do {
            try prepareDirectories()
            let data = try Data(contentsOf: stateURL)
            return try decoder.decode(AppSnapshot.self, from: data)
        } catch {
            return AppSnapshot(settings: .init(), ipaHistory: [], webHistory: [])
        }
    }

    func saveSnapshot(_ snapshot: AppSnapshot) {
        snapshotWriter.scheduleSave(snapshot, rootDirectory: rootDirectory, downloadsDirectory: downloadsDirectory, stateURL: stateURL)
    }

    func saveSnapshotSynchronously(_ snapshot: AppSnapshot) {
        do {
            try Self.writeSnapshot(snapshot, rootDirectory: rootDirectory, downloadsDirectory: downloadsDirectory, stateURL: stateURL)
        } catch {
            assertionFailure("Failed to save snapshot: \(error)")
        }
    }

    func exportPayload(snapshot: AppSnapshot) -> String? {
        let exportedHistory = snapshot.ipaHistory.map { record in
            ExportedIpaRecord(
                id: record.id,
                title: record.title,
                version: record.version,
                bundleIdentifier: record.bundleIdentifier,
                downloadURL: record.downloadURL,
                iconURL: record.iconURL,
                fromPageURL: record.fromPageURL,
                createdAt: record.createdAt
            )
        }

        let export = ExportBundle(ipaHistory: exportedHistory, webHistory: snapshot.webHistory)

        do {
            let data = try Self.makeEncoder().encode(export)
            return String(decoding: data, as: UTF8.self)
        } catch {
            return nil
        }
    }

    func importPayload(_ text: String) throws -> ImportBundle {
        guard let data = text.data(using: .utf8) else {
            throw ImportError.invalidEncoding
        }

        if let modern = try? decoder.decode(ExportBundle.self, from: data) {
            return ImportBundle(
                ipaHistory: modern.ipaHistory.map(\.record),
                webHistory: modern.webHistory
            )
        }

        if let legacy = try? decoder.decode(LegacyExportBundle.self, from: data) {
            return ImportBundle(
                ipaHistory: legacy.ipaHistory.map(\.record),
                webHistory: legacy.webHistory.compactMap(\.entry)
            )
        }

        throw ImportError.invalidPayload
    }

    func deleteFileIfNeeded(at url: URL) {
        try? fileManager.removeItem(at: url)
    }

    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    func fileSize(at url: URL) -> Int64 {
        let attributes = try? fileManager.attributesOfItem(atPath: url.path)
        return attributes?[.size] as? Int64 ?? 0
    }

    fileprivate static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    fileprivate static func writeSnapshot(
        _ snapshot: AppSnapshot,
        rootDirectory: URL,
        downloadsDirectory: URL,
        stateURL: URL
    ) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true, attributes: nil)
        let data = try makeEncoder().encode(snapshot)
        try data.write(to: stateURL, options: .atomic)
    }
}

private final class SnapshotWriter: @unchecked Sendable {
    private let queue = DispatchQueue(label: "PersistenceController.SnapshotWriter", qos: .utility)
    private var pendingSnapshot: AppSnapshot?
    private var pendingRootDirectory: URL?
    private var pendingDownloadsDirectory: URL?
    private var pendingStateURL: URL?
    private var isSaving = false

    func scheduleSave(_ snapshot: AppSnapshot, rootDirectory: URL, downloadsDirectory: URL, stateURL: URL) {
        queue.async {
            self.pendingSnapshot = snapshot
            self.pendingRootDirectory = rootDirectory
            self.pendingDownloadsDirectory = downloadsDirectory
            self.pendingStateURL = stateURL

            guard !self.isSaving else { return }
            self.isSaving = true
            self.drainQueue()
        }
    }

    private func drainQueue() {
        queue.async {
            guard
                let snapshot = self.pendingSnapshot,
                let rootDirectory = self.pendingRootDirectory,
                let downloadsDirectory = self.pendingDownloadsDirectory,
                let stateURL = self.pendingStateURL
            else {
                self.isSaving = false
                return
            }

            self.pendingSnapshot = nil

            do {
                try PersistenceController.writeSnapshot(
                    snapshot,
                    rootDirectory: rootDirectory,
                    downloadsDirectory: downloadsDirectory,
                    stateURL: stateURL
                )
            } catch {
                assertionFailure("Failed to save snapshot: \(error)")
            }

            self.drainQueue()
        }
    }
}

enum ImportError: LocalizedError {
    case invalidEncoding
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .invalidEncoding:
            L10n.string("import.error.invalidEncoding")
        case .invalidPayload:
            L10n.string("import.error.invalidPayload")
        }
    }
}

struct ImportBundle {
    var ipaHistory: [IpaRecord]
    var webHistory: [WebHistoryEntry]
}

private struct ExportBundle: Codable {
    var ipaHistory: [ExportedIpaRecord]
    var webHistory: [WebHistoryEntry]
}

private struct ExportedIpaRecord: Codable {
    var id: String
    var title: String
    var version: String?
    var bundleIdentifier: String?
    var downloadURL: String
    var iconURL: String?
    var fromPageURL: String?
    var createdAt: Date

    var record: IpaRecord {
        IpaRecord(
            id: id,
            title: title,
            version: version,
            bundleIdentifier: bundleIdentifier,
            downloadURL: downloadURL,
            iconURL: iconURL,
            fromPageURL: fromPageURL,
            createdAt: createdAt,
            localFileName: nil
        )
    }
}

private struct LegacyExportBundle: Decodable {
    var ipaHistory: [LegacyIpaRecord]
    var webHistory: [LegacyWebHistoryEntry]
}

private struct LegacyIpaRecord: Decodable {
    var sign: String?
    var title: String?
    var version: String?
    var bundleId: String?
    var downloadUrl: String?
    var iconUrl: String?
    var fromPageUrl: String?
    var time: String?

    var record: IpaRecord {
        let parsedDate = time.flatMap { DateFormatter.legacyImportTimestamp.date(from: $0) } ?? .now
        return IpaRecord(
            id: sign ?? UUID().uuidString,
            title: title ?? L10n.string("common.untitledApp"),
            version: version,
            bundleIdentifier: bundleId,
            downloadURL: downloadUrl ?? "",
            iconURL: iconUrl,
            fromPageURL: fromPageUrl,
            createdAt: parsedDate,
            localFileName: nil
        )
    }
}

private struct LegacyWebHistoryEntry: Decodable {
    var title: String?
    var url: String
    var host: String
    var faviconURL: String?
    var lastVisitedAt: Date

    enum CodingKeys: String, CodingKey {
        case title
        case url
        case urlStr
        case host
        case hostStr
        case favicon
        case faviconURL
        case time
        case lastVisitedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        url = try container.decodeIfPresent(String.self, forKey: .urlStr)
            ?? container.decodeIfPresent(String.self, forKey: .url)
            ?? ""

        let derivedHost = URL(string: url)?.host ?? url
        host = try container.decodeIfPresent(String.self, forKey: .hostStr)
            ?? container.decodeIfPresent(String.self, forKey: .host)
            ?? derivedHost

        faviconURL = try container.decodeIfPresent(String.self, forKey: .favicon)
            ?? container.decodeIfPresent(String.self, forKey: .faviconURL)

        if let decodedDate = try? container.decodeIfPresent(Date.self, forKey: .lastVisitedAt) {
            lastVisitedAt = decodedDate
        } else {
            let rawDate = try container.decodeIfPresent(String.self, forKey: .lastVisitedAt)
                ?? container.decodeIfPresent(String.self, forKey: .time)
            lastVisitedAt = Self.parseDate(rawDate) ?? .now
        }
    }

    var entry: WebHistoryEntry? {
        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else { return nil }

        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedHost = host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (URL(string: trimmedURL)?.host ?? trimmedURL) : host

        return WebHistoryEntry(
            id: UUID(),
            title: trimmedTitle.isEmpty ? resolvedHost : trimmedTitle,
            url: trimmedURL,
            host: resolvedHost,
            faviconURL: faviconURL,
            lastVisitedAt: lastVisitedAt
        )
    }

    private static func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }
        return DateFormatter.legacyImportTimestamp.date(from: value)
            ?? Self.iso8601Formatter.date(from: value)
            ?? Self.iso8601FractionalFormatter.date(from: value)
    }

    private static let iso8601Formatter = ISO8601DateFormatter()
    private static let iso8601FractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
