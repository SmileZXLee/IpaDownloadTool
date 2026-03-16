import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    @State private var blockedHostsText = ""
    @State private var mobileRulesText = ""
    @State private var virtualUDID = ""

    var body: some View {
        NavigationStack {
            Form {
                // General
                Section {
                    Toggle("settings.developerMode", isOn: $model.settings.developerMode)
                        .onChange(of: model.settings.developerMode) { _, _ in
                            model.persist()
                        }

                    LabeledContent("settings.virtualUDID") {
                        TextField("settings.virtualUDID.placeholder", text: $virtualUDID)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                            .onSubmit {
                                model.settings.virtualUDID = virtualUDID
                                model.persist()
                            }
                    }
                }

                // Blocked Hosts
                Section("settings.blockedHosts") {
                    TextEditor(text: $blockedHostsText)
                        .frame(minHeight: 80)
                        .font(.body.monospaced())
                        .onChange(of: blockedHostsText) { _, value in
                            model.settings.blockedHosts = parseLines(value)
                            model.persist()
                        }
                }

                // Mobile Provision Rules
                Section("settings.mobileProvisionRules") {
                    TextEditor(text: $mobileRulesText)
                        .frame(minHeight: 80)
                        .font(.body.monospaced())
                        .onChange(of: mobileRulesText) { _, value in
                            model.settings.mobileProvisionRules = parseLines(value)
                            model.persist()
                        }
                }

                // Data Management
                Section {
                    Button("settings.action.export") {
                        model.prepareExport()
                    }

                    Button("settings.action.import") {
                        model.importFromPasteboard()
                    }
                }

                // About
                Section {
                    Link(destination: URL(string: "https://github.com/SmileZXLee/IpaDownloadTool")!) {
                        Label("settings.opensource", systemImage: "arrow.up.right.square")
                    }
                } footer: {
                    Text(L10n.formatted("settings.summary", model.ipaHistory.count, model.webHistory.count))
                }
            }
            .navigationTitle("settings.navigation.title")
            .onAppear {
                blockedHostsText = model.settings.blockedHosts.joined(separator: "\n")
                mobileRulesText = model.settings.mobileProvisionRules.joined(separator: "\n")
                virtualUDID = model.settings.virtualUDID
            }
        }
    }

    private func parseLines(_ text: String) -> [String] {
        text
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
