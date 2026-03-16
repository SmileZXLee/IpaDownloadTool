import SwiftUI

struct HistoryView: View {
    @ObservedObject var model: AppModel
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if model.sortedHistory.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("history.empty.title", systemImage: "tray")
                        },
                        description: {
                            Text("history.empty.detail")
                        }
                    )
                } else {
                    List {
                        Picker("history.sort.label", selection: $model.settings.historySort) {
                            ForEach(HistorySort.allCases) { sort in
                                Text(sort.titleKey).tag(sort)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))

                        ForEach(model.sortedHistory) { record in
                            Button {
                                model.presentedRecordID = record.id
                            } label: {
                                HistoryRow(record: record)
                            }
                            .contextMenu {
                                Button {
                                    model.presentedRecordID = record.id
                                } label: {
                                    Label("history.action.viewDetails", systemImage: "info.circle")
                                }
                                Button {
                                    model.startDownload(for: record.id)
                                } label: {
                                    Label("history.action.startDownload", systemImage: "arrow.down.circle")
                                }
                                Divider()
                                Button(role: .destructive) {
                                    model.deleteHistoryRecord(record.id)
                                } label: {
                                    Label("history.action.delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    model.deleteHistoryRecord(record.id)
                                } label: {
                                    Label("history.action.delete", systemImage: "trash")
                                }
                                Button {
                                    model.startDownload(for: record.id)
                                } label: {
                                    Label("history.action.startDownload", systemImage: "arrow.down.circle")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .onChange(of: model.settings.historySort) { _, _ in
                        model.persist()
                    }
                }
            }
            .navigationTitle("history.navigation.title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !model.sortedHistory.isEmpty {
                        Button("history.action.clear", role: .destructive) {
                            showClearConfirmation = true
                        }
                    }
                }
            }
            .confirmationDialog(
                "history.clear.confirm.title",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("history.action.clear", role: .destructive) {
                    model.clearHistory()
                }
                Button("common.cancel", role: .cancel) {}
            } message: {
                Text("history.clear.confirm.message")
            }
        }
    }
}

// MARK: - History Row

private struct HistoryRow: View {
    let record: IpaRecord

    var body: some View {
        HStack(spacing: 14) {
            IpaArtworkView(title: record.displayTitle, iconURL: record.iconURL, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.displayTitle)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let version = record.version, !version.isEmpty {
                        Text("v\(version)")
                            .foregroundStyle(.secondary)
                    }
                    if record.hasLocalFile {
                        Label("history.badge.downloaded", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .font(.caption)

                Text(record.createdAt.localizedTimestamp)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - IPA Detail View

struct IpaDetailView: View {
    @ObservedObject var model: AppModel
    let recordID: String

    @State private var draftTitle = ""

    private var record: IpaRecord? {
        model.record(for: recordID)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let record {
                    Form {
                        // Header
                        Section {
                            HStack(spacing: 16) {
                                IpaArtworkView(title: record.displayTitle, iconURL: record.iconURL, size: 64)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.displayTitle)
                                        .font(.title3.weight(.semibold))
                                    if let version = record.version, !version.isEmpty {
                                        Text("v\(version)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    if record.hasLocalFile {
                                        Label(model.fileSizeText(for: record), systemImage: "internaldrive")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 6)
                        }

                        // Name editor
                        Section("history.detail.appName") {
                            TextField("history.detail.appNamePlaceholder", text: $draftTitle)
                                .autocorrectionDisabled()
                                .onSubmit {
                                    model.renameRecord(id: recordID, title: draftTitle)
                                }
                        }

                        // Metadata
                        Section("history.detail.info") {
                            DetailInfoRow("history.detail.bundleIdentifier", value: record.bundleIdentifier ?? "—")
                            DetailInfoRow("history.detail.downloadURL", value: record.downloadURL)
                            DetailInfoRow("history.detail.sourceURL", value: record.fromPageURL ?? "—")
                            DetailInfoRow("history.detail.createdAt", value: record.createdAt.localizedTimestamp)
                        }

                        // Actions
                        Section {
                            Button("history.detail.downloadAgain") {
                                model.startDownload(for: record.id)
                            }

                            if let fileURL = model.localFileURL(for: record), fileURL.isFileURL {
                                ShareLink(item: fileURL) {
                                    Label("history.detail.shareLocalIPA", systemImage: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                    .onAppear {
                        draftTitle = record.displayTitle
                    }
                } else {
                    ContentUnavailableView(
                        label: {
                            Label("history.detail.missing.title", systemImage: "exclamationmark.triangle")
                        },
                        description: {
                            Text("history.detail.missing.detail")
                        }
                    )
                }
            }
            .navigationTitle("history.detail.navigation.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.done") {
                        model.presentedRecordID = nil
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Detail Info Row

private struct DetailInfoRow: View {
    let title: LocalizedStringKey
    let value: String

    init(_ title: LocalizedStringKey, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
        .padding(.vertical, 2)
    }
}
