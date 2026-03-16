import Foundation
import Combine
import UIKit

@MainActor
final class AppModel: ObservableObject {
    @Published var settings: AppSettings {
        didSet {
            guard oldValue.historySort != settings.historySort else { return }
            rebuildHistoryCaches()
        }
    }
    @Published var ipaHistory: [IpaRecord] {
        didSet {
            fileSizeTextCache.removeAll()
            rebuildHistoryCaches()
        }
    }
    @Published var webHistory: [WebHistoryEntry]
    @Published var downloads: [DownloadItem] = []
    @Published var selectedTab: RootTab = .browser
    @Published var presentedRecordID: String?
    @Published var notice: AppNotice?
    @Published var sharePayload: SharePayload?
    @Published var pasteboardPromptURL: String?
    @Published var pendingBrowserLoadURL: String?
    @Published var showAgreementSheet = false

    private let persistence = PersistenceController()
    private let downloadCoordinator = DownloadCoordinator()
    private var hasActivated = false
    private var sortedHistoryCache: [IpaRecord] = []
    private var downloadedHistoryCache: [IpaRecord] = []
    private var fileSizeTextCache: [String: String] = [:]

    init() {
        let snapshot = persistence.loadSnapshot()
        settings = snapshot.settings
        ipaHistory = snapshot.ipaHistory
        webHistory = snapshot.webHistory
        rebuildHistoryCaches()

        downloadCoordinator.eventHandler = { [weak self] event in
            Task { @MainActor in
                self?.handleDownloadEvent(event)
            }
        }
    }

    var sortedHistory: [IpaRecord] {
        sortedHistoryCache
    }

    var downloadedHistory: [IpaRecord] {
        downloadedHistoryCache
    }

    func activate() {
        if !hasActivated {
            hasActivated = true
            showAgreementSheet = !settings.userAgreementAccepted
        }
        checkPasteboard()
        cleanupMissingFiles()
    }

    func persist(synchronously: Bool = false) {
        if synchronously {
            persistence.saveSnapshotSynchronously(snapshot)
        } else {
            persistence.saveSnapshot(snapshot)
        }
    }

    var snapshot: AppSnapshot {
        AppSnapshot(settings: settings, ipaHistory: ipaHistory, webHistory: webHistory)
    }

    func acceptAgreement() {
        settings.userAgreementAccepted = true
        showAgreementSheet = false
        persist()
    }

    func handleIncomingURL(_ url: URL) {
        pendingBrowserLoadURL = url.absoluteString
        settings.lastPasteboardURL = url.absoluteString
        selectedTab = .browser
        persist()
    }

    func loadFromPasteboardPrompt() {
        guard let pasteboardPromptURL else { return }
        pendingBrowserLoadURL = pasteboardPromptURL
        settings.lastPasteboardURL = pasteboardPromptURL
        self.pasteboardPromptURL = nil
        selectedTab = .browser
        persist()
    }

    func dismissPasteboardPrompt() {
        if let pasteboardPromptURL {
            settings.lastPasteboardURL = pasteboardPromptURL
        }
        self.pasteboardPromptURL = nil
        persist()
    }

    func updateLastLoadedURL(_ value: String) {
        settings.lastLoadedURL = value
        persist()
    }

    func registerVisitedPage(title: String, url: String, host: String, faviconURL: String?) {
        guard !url.isEmpty else { return }
        let entry = WebHistoryEntry(
            id: UUID(),
            title: title.isEmpty ? host : title,
            url: url,
            host: host,
            faviconURL: faviconURL,
            lastVisitedAt: .now
        )

        webHistory.removeAll { $0.url == url }
        webHistory.insert(entry, at: 0)
        persist()
    }

    func upsertRecord(_ record: IpaRecord, present: Bool = true) {
        if let existingIndex = ipaHistory.firstIndex(where: { $0.id == record.id }) {
            var merged = record
            merged.localFileName = ipaHistory[existingIndex].localFileName ?? record.localFileName
            ipaHistory[existingIndex] = merged
        } else {
            ipaHistory.insert(record, at: 0)
        }

        if present {
            presentedRecordID = record.id
        }
        selectedTab = .history
        persist()
    }

    func renameRecord(id: String, title: String) {
        guard let index = ipaHistory.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        ipaHistory[index].title = trimmed
        persist()
    }

    func record(for id: String) -> IpaRecord? {
        ipaHistory.first(where: { $0.id == id })
    }

    func deleteHistoryRecord(_ id: String) {
        cancelDownload(id)

        if let record = record(for: id), let fileURL = localFileURL(for: record) {
            persistence.deleteFileIfNeeded(at: fileURL)
        }
        ipaHistory.removeAll { $0.id == id }
        downloads.removeAll { $0.recordID == id }
        persist()
    }

    func clearHistory() {
        downloads
            .filter { $0.state == .queued || $0.state == .downloading }
            .forEach { cancelDownload($0.recordID) }
        ipaHistory.compactMap(localFileURL(for:)).forEach(persistence.deleteFileIfNeeded(at:))
        ipaHistory.removeAll()
        downloads.removeAll()
        persist()
    }

    func clearWebHistory() {
        webHistory.removeAll()
        persist()
    }

    func startDownload(for id: String) {
        guard let record = record(for: id) else { return }
        guard let sourceURL = URL(string: record.downloadURL) else {
            notice = AppNotice(
                title: L10n.string("notice.downloadFailed.title"),
                message: L10n.string("notice.downloadFailed.invalidURL")
            )
            return
        }

        do {
            downloadCoordinator.cancel(recordID: record.id, emitEvent: false)
            try persistence.prepareDirectories()
            let destination = downloadDestination(for: record)
            updateDownload(
                DownloadItem(
                    id: record.id,
                    recordID: record.id,
                    title: record.displayFileName,
                    sourceURL: record.downloadURL,
                    destinationURL: destination.finalURL,
                    receivedBytes: 0,
                    expectedBytes: 0,
                    state: .queued,
                    errorMessage: nil
                )
            )
            downloadCoordinator.start(recordID: record.id, sourceURL: sourceURL, destination: destination)
            selectedTab = .downloads
        } catch {
            notice = AppNotice(title: L10n.string("notice.downloadFailed.title"), message: error.localizedDescription)
        }
    }

    func cancelDownload(_ id: String) {
        downloadCoordinator.cancel(recordID: id)
    }

    func prepareExport() {
        guard let text = persistence.exportPayload(snapshot: snapshot) else {
            notice = AppNotice(
                title: L10n.string("notice.exportFailed.title"),
                message: L10n.string("notice.exportFailed.message")
            )
            return
        }
        sharePayload = SharePayload(text: text)
    }

    func importFromPasteboard() {
        guard let content = UIPasteboard.general.string, !content.isEmpty else {
            notice = AppNotice(
                title: L10n.string("notice.importFailed.title"),
                message: L10n.string("notice.importFailed.emptyPasteboard")
            )
            return
        }

        do {
            let imported = try persistence.importPayload(content)

            var updatedHistory = ipaHistory
            for record in imported.ipaHistory where !record.downloadURL.isEmpty {
                if let existingIndex = updatedHistory.firstIndex(where: { $0.id == record.id }) {
                    var merged = record
                    merged.localFileName = updatedHistory[existingIndex].localFileName ?? record.localFileName
                    updatedHistory[existingIndex] = merged
                } else {
                    updatedHistory.insert(record, at: 0)
                }
            }

            ipaHistory = updatedHistory

            var updatedWebHistory = webHistory
            for entry in imported.webHistory {
                updatedWebHistory.removeAll { $0.url == entry.url }
                updatedWebHistory.insert(entry, at: 0)
            }

            webHistory = updatedWebHistory
            persist()
            notice = AppNotice(
                title: L10n.string("notice.importComplete.title"),
                message: L10n.importCompleteMessage(
                    ipaCount: imported.ipaHistory.count,
                    webHistoryCount: imported.webHistory.count
                )
            )
        } catch {
            notice = AppNotice(title: L10n.string("notice.importFailed.title"), message: error.localizedDescription)
        }
    }

    func localFileURL(for record: IpaRecord) -> URL? {
        guard let localFileName = record.localFileName else { return nil }
        return persistence.downloadsDirectory.appendingPathComponent(localFileName, isDirectory: false)
    }

    func fileSizeText(for record: IpaRecord) -> String {
        if let cached = fileSizeTextCache[record.id] {
            return cached
        }

        guard let localFileURL = localFileURL(for: record) else { return L10n.string("common.notDownloaded") }
        guard persistence.fileExists(at: localFileURL) else { return L10n.string("common.notDownloaded") }

        let text = ByteCountFormatter.appFileSizeString(from: persistence.fileSize(at: localFileURL))
        fileSizeTextCache[record.id] = text
        return text
    }

    private func checkPasteboard() {
        guard settings.userAgreementAccepted else { return }
        guard let value = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return
        }

        let prefixes = ["http://", "https://", "itms-services://"]
        guard prefixes.contains(where: value.hasPrefix) else { return }
        guard !value.hasSuffix(".ipa") else { return }
        guard settings.lastPasteboardURL != value else { return }
        pasteboardPromptURL = value
    }

    private func cleanupMissingFiles() {
        var updatedHistory = ipaHistory
        var didChange = false
        for index in updatedHistory.indices {
            guard let fileURL = localFileURL(for: updatedHistory[index]) else { continue }
            if !persistence.fileExists(at: fileURL) {
                updatedHistory[index].localFileName = nil
                didChange = true
            }
        }
        if didChange {
            ipaHistory = updatedHistory
            persist()
        }
    }

    private func handleDownloadEvent(_ event: DownloadCoordinator.Event) {
        switch event {
        case let .progress(recordID, receivedBytes, expectedBytes):
            updateDownloadProgress(recordID: recordID, receivedBytes: receivedBytes, expectedBytes: expectedBytes)
        case let .finished(recordID, fileName):
            if let index = ipaHistory.firstIndex(where: { $0.id == recordID }) {
                if let previousFileName = ipaHistory[index].localFileName, previousFileName != fileName {
                    let previousURL = persistence.downloadsDirectory.appendingPathComponent(previousFileName, isDirectory: false)
                    persistence.deleteFileIfNeeded(at: previousURL)
                }
                ipaHistory[index].localFileName = fileName
            }
            markDownloadFinished(recordID: recordID)
            persist()
        case let .failed(recordID, message):
            markDownloadFailed(recordID: recordID, message: message)
        case let .cancelled(recordID):
            downloads.removeAll { $0.recordID == recordID }
        }
    }

    private func updateDownload(_ item: DownloadItem) {
        if let index = downloads.firstIndex(where: { $0.recordID == item.recordID }) {
            downloads[index] = item
        } else {
            downloads.insert(item, at: 0)
        }
    }

    private func updateDownloadProgress(recordID: String, receivedBytes: Int64, expectedBytes: Int64) {
        guard let index = downloads.firstIndex(where: { $0.recordID == recordID }) else { return }
        downloads[index].receivedBytes = receivedBytes
        downloads[index].expectedBytes = expectedBytes
        downloads[index].state = .downloading
    }

    private func markDownloadFinished(recordID: String) {
        guard let index = downloads.firstIndex(where: { $0.recordID == recordID }) else { return }
        downloads[index].receivedBytes = max(downloads[index].expectedBytes, downloads[index].receivedBytes)
        downloads[index].state = .finished
        downloads[index].errorMessage = nil
    }

    private func markDownloadFailed(recordID: String, message: String) {
        guard let index = downloads.firstIndex(where: { $0.recordID == recordID }) else { return }
        downloads[index].state = .failed
        downloads[index].errorMessage = message
    }

    private func downloadDestination(for record: IpaRecord) -> DownloadCoordinator.Destination {
        let fileName = "\(record.id)-\(record.displayFileName)"
        let sanitizedFileName = fileName.replacingOccurrences(of: "/", with: "-")
        let finalURL = persistence.downloadsDirectory.appendingPathComponent(sanitizedFileName, isDirectory: false)

        let shouldPreserveExistingFile = record.localFileName
            .map { persistence.downloadsDirectory.appendingPathComponent($0, isDirectory: false) }
            .map(persistence.fileExists(at:))
            ?? false

        if shouldPreserveExistingFile {
            let stagingFileName = "\(record.id)-\(UUID().uuidString).download"
            let stagingURL = persistence.downloadsDirectory.appendingPathComponent(stagingFileName, isDirectory: false)
            persistence.deleteFileIfNeeded(at: stagingURL)
            return DownloadCoordinator.Destination(stagingURL: stagingURL, finalURL: finalURL)
        }

        persistence.deleteFileIfNeeded(at: finalURL)
        return DownloadCoordinator.Destination(stagingURL: finalURL, finalURL: finalURL)
    }

    private func rebuildHistoryCaches() {
        switch settings.historySort {
        case .createdAtDescending:
            sortedHistoryCache = ipaHistory.sorted { $0.createdAt > $1.createdAt }
        case .fileNameAscending:
            sortedHistoryCache = ipaHistory.sorted {
                $0.displayTitle.localizedStandardCompare($1.displayTitle) == .orderedAscending
            }
        }

        downloadedHistoryCache = ipaHistory
            .filter(\.hasLocalFile)
            .sorted { $0.createdAt > $1.createdAt }
    }
}

private final class DownloadCoordinator: NSObject, URLSessionDownloadDelegate {
    struct Destination {
        var stagingURL: URL
        var finalURL: URL
    }

    enum Event {
        case progress(recordID: String, receivedBytes: Int64, expectedBytes: Int64)
        case finished(recordID: String, fileName: String)
        case failed(recordID: String, message: String)
        case cancelled(recordID: String)
    }

    var eventHandler: ((Event) -> Void)?

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private var taskMap: [Int: TaskContext] = [:]
    private var recordTasks: [String: URLSessionDownloadTask] = [:]

    struct TaskContext {
        var recordID: String
        var stagingURL: URL
        var finalURL: URL
        var lastReportedBytes: Int64 = 0
        var lastReportTime: Date = .distantPast
    }

    func start(recordID: String, sourceURL: URL, destination: Destination) {
        var request = URLRequest(url: sourceURL)
        request.setValue("com.apple.appstored/1.0 iOS/18.0", forHTTPHeaderField: "User-Agent")
        let task = session.downloadTask(with: request)
        taskMap[task.taskIdentifier] = TaskContext(
            recordID: recordID,
            stagingURL: destination.stagingURL,
            finalURL: destination.finalURL
        )
        recordTasks[recordID] = task
        task.resume()
    }

    func cancel(recordID: String, emitEvent: Bool = true) {
        guard let task = recordTasks[recordID] else { return }
        task.cancel()
        _ = removeTask(task.taskIdentifier)

        if emitEvent {
            eventHandler?(.cancelled(recordID: recordID))
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard var context = taskMap[downloadTask.taskIdentifier] else { return }
        let now = Date()
        let hasFinished = totalBytesExpectedToWrite > 0 && totalBytesWritten >= totalBytesExpectedToWrite
        let crossedByteThreshold = totalBytesWritten - context.lastReportedBytes >= 256 * 1024
        let crossedTimeThreshold = now.timeIntervalSince(context.lastReportTime) >= 0.2

        guard hasFinished || crossedByteThreshold || crossedTimeThreshold else { return }

        context.lastReportedBytes = totalBytesWritten
        context.lastReportTime = now
        taskMap[downloadTask.taskIdentifier] = context
        eventHandler?(.progress(recordID: context.recordID, receivedBytes: totalBytesWritten, expectedBytes: totalBytesExpectedToWrite))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let context = taskMap[downloadTask.taskIdentifier] else { return }
        let fileManager = FileManager.default

        do {
            try? fileManager.removeItem(at: context.stagingURL)
            try fileManager.moveItem(at: location, to: context.stagingURL)

            let completedURL: URL
            if context.stagingURL == context.finalURL {
                completedURL = context.finalURL
            } else if fileManager.fileExists(atPath: context.finalURL.path) {
                completedURL = try fileManager.replaceItemAt(
                    context.finalURL,
                    withItemAt: context.stagingURL,
                    backupItemName: nil
                ) ?? context.finalURL
            } else {
                try fileManager.moveItem(at: context.stagingURL, to: context.finalURL)
                completedURL = context.finalURL
            }

            eventHandler?(.finished(recordID: context.recordID, fileName: completedURL.lastPathComponent))
        } catch {
            if context.stagingURL != context.finalURL {
                try? fileManager.removeItem(at: context.stagingURL)
            }
            eventHandler?(.failed(recordID: context.recordID, message: error.localizedDescription))
        }

        _ = removeTask(downloadTask.taskIdentifier)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let context = taskMap[task.taskIdentifier] else { return }
        defer { _ = removeTask(task.taskIdentifier) }

        if let error {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled {
                eventHandler?(.cancelled(recordID: context.recordID))
            } else {
                eventHandler?(.failed(recordID: context.recordID, message: error.localizedDescription))
            }
        }
    }

    private func removeTask(_ taskIdentifier: Int) -> TaskContext? {
        guard let context = taskMap.removeValue(forKey: taskIdentifier) else { return nil }
        recordTasks.removeValue(forKey: context.recordID)
        return context
    }
}
