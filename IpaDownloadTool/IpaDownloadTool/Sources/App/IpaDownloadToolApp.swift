import SwiftUI

@main
struct IpaDownloadToolApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .onOpenURL { url in
                    model.handleIncomingURL(url)
                }
                .task {
                    model.activate()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        model.activate()
                    }
                    if newPhase == .background {
                        model.persist(synchronously: true)
                    }
                }
        }
    }
}
