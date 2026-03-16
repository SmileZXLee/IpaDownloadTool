import SwiftUI

struct DownloadsView: View {
    @ObservedObject var model: AppModel
    @State private var mode = 0

    var body: some View {
        NavigationStack {
            List {
                Picker("downloads.mode.label", selection: $mode) {
                    Text("downloads.mode.inProgress").tag(0)
                    Text("downloads.mode.completed").tag(1)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))

                if mode == 0 {
                    ForEach(model.downloads) { item in
                        DownloadRow(item: item) {
                            model.cancelDownload(item.recordID)
                        }
                    }
                } else {
                    ForEach(model.downloadedHistory) { record in
                        Button {
                            model.presentedRecordID = record.id
                        } label: {
                            DownloadedRow(record: record, model: model)
                        }
                        .swipeActions(edge: .trailing) {
                            if let fileURL = model.localFileURL(for: record) {
                                ShareLink(item: fileURL) {
                                    Label("history.detail.shareLocalIPA", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("downloads.navigation.title")
            .overlay {
                if mode == 0 && model.downloads.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("downloads.empty.inProgress.title", systemImage: "arrow.down.circle.dotted")
                        },
                        description: {
                            Text("downloads.empty.inProgress.detail")
                        }
                    )
                } else if mode == 1 && model.downloadedHistory.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("downloads.empty.completed.title", systemImage: "internaldrive")
                        },
                        description: {
                            Text("downloads.empty.completed.detail")
                        }
                    )
                }
            }
        }
    }
}

// MARK: - In-Progress Download Row

private struct DownloadRow: View {
    let item: DownloadItem
    let cancelAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.title)
                    .font(.body)
                    .lineLimit(2)

                Spacer(minLength: 8)

                Text(item.state.titleKey)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: item.expectedBytes > 0 ? item.progress : nil)
                .progressViewStyle(.linear)
                .animation(.easeInOut, value: item.progress)

            HStack {
                Text(ByteCountFormatter.appFileSizeString(from: item.receivedBytes))
                Spacer()
                if item.expectedBytes > 0 {
                    Text(ByteCountFormatter.appFileSizeString(from: item.expectedBytes))
                } else {
                    Text("downloads.size.calculating")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let errorMessage = item.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if item.state == .downloading || item.state == .queued {
                Button(action: cancelAction) {
                    Label("downloads.action.cancel", systemImage: "xmark")
                }
                .tint(.red)
            }
        }
    }
}

// MARK: - Completed Download Row

private struct DownloadedRow: View {
    let record: IpaRecord
    let model: AppModel

    var body: some View {
        HStack(spacing: 14) {
            IpaArtworkView(title: record.displayTitle, iconURL: record.iconURL, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.displayFileName)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(model.fileSizeText(for: record))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
