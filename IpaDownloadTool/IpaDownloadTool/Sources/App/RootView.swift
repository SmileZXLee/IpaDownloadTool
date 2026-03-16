import SwiftUI

struct RootView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            Tab("tab.browser", systemImage: "globe", value: RootTab.browser) {
                BrowserView(model: model)
            }

            Tab("tab.history", systemImage: "clock.fill", value: RootTab.history) {
                HistoryView(model: model)
            }

            Tab("tab.downloads", systemImage: "arrow.down.circle.fill", value: RootTab.downloads) {
                DownloadsView(model: model)
            }

            Tab("tab.settings", systemImage: "gearshape.fill", value: RootTab.settings) {
                SettingsView(model: model)
            }
        }
        .sheet(
            isPresented: Binding(
                get: { model.presentedRecordID != nil },
                set: { if !$0 { model.presentedRecordID = nil } }
            )
        ) {
            if let recordID = model.presentedRecordID {
                IpaDetailView(model: model, recordID: recordID)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(item: $model.sharePayload) { payload in
            ShareSheet(items: [payload.text])
        }
        .sheet(isPresented: $model.showAgreementSheet) {
            AgreementSheetView(model: model)
        }
        .confirmationDialog(
            "root.pasteboard.title",
            isPresented: Binding(
                get: { model.pasteboardPromptURL != nil },
                set: { if !$0 { model.pasteboardPromptURL = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("root.pasteboard.open") {
                model.loadFromPasteboardPrompt()
            }
            Button("root.pasteboard.ignore", role: .cancel) {
                model.dismissPasteboardPrompt()
            }
        } message: {
            Text(model.pasteboardPromptURL ?? "")
        }
        .alert(
            model.notice?.title ?? "",
            isPresented: Binding(
                get: { model.notice != nil },
                set: { if !$0 { model.notice = nil } }
            ),
            presenting: model.notice
        ) { _ in
            Button("common.ok") { model.notice = nil }
        } message: { notice in
            Text(notice.message)
        }
    }
}
