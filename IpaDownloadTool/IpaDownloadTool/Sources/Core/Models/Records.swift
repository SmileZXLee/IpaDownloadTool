import Foundation
import SwiftUI

enum RootTab: Hashable {
    case browser
    case history
    case downloads
    case settings
}

enum HistorySort: String, Codable, CaseIterable, Identifiable {
    case createdAtDescending
    case fileNameAscending

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .createdAtDescending:
            "history.sort.createdAt"
        case .fileNameAscending:
            "history.sort.fileName"
        }
    }
}

struct IpaRecord: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var title: String
    var version: String?
    var bundleIdentifier: String?
    var downloadURL: String
    var iconURL: String?
    var fromPageURL: String?
    var createdAt: Date
    var localFileName: String?

    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.string("common.untitledApp") : trimmed
    }

    var displayFileName: String {
        let safeTitle = displayTitle.replacingOccurrences(of: "/", with: "-")
        if let version, !version.isEmpty {
            return "\(safeTitle)(v\(version)).ipa"
        }
        return "\(safeTitle).ipa"
    }

    var hasLocalFile: Bool {
        localFileName != nil
    }
}

struct WebHistoryEntry: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var title: String
    var url: String
    var host: String
    var faviconURL: String?
    var lastVisitedAt: Date
}

enum DownloadState: String, Codable, Hashable, Sendable {
    case queued
    case downloading
    case finished
    case failed
    case cancelled

    var titleKey: LocalizedStringKey {
        switch self {
        case .queued:
            "downloads.state.queued"
        case .downloading:
            "downloads.state.downloading"
        case .finished:
            "downloads.state.finished"
        case .failed:
            "downloads.state.failed"
        case .cancelled:
            "downloads.state.cancelled"
        }
    }
}

struct DownloadItem: Identifiable, Hashable {
    var id: String
    var recordID: String
    var title: String
    var sourceURL: String
    var destinationURL: URL
    var receivedBytes: Int64
    var expectedBytes: Int64
    var state: DownloadState
    var errorMessage: String?

    var progress: Double {
        guard expectedBytes > 0 else { return 0 }
        return Double(receivedBytes) / Double(expectedBytes)
    }
}

struct AppSettings: Codable, Hashable, Sendable {
    var userAgreementAccepted = false
    var developerMode = false
    var blockedHosts = ["www.pgyer.com", "fir.im"]
    var mobileProvisionRules = ["*.mobileconfig", "*.mobileprovision", "*/tools/udid/get/"]
    var virtualUDID = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    var lastLoadedURL = ""
    var lastPasteboardURL = ""
    var historySort: HistorySort = .createdAtDescending
}

struct AppSnapshot: Codable, Sendable {
    var settings: AppSettings
    var ipaHistory: [IpaRecord]
    var webHistory: [WebHistoryEntry]
}

struct SharePayload: Identifiable, Hashable {
    let id = UUID()
    let text: String
}

struct AppNotice: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
}

extension DateFormatter {
    static let legacyImportTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
