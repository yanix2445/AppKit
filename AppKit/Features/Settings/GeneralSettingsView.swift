import AppKit
import AppKitCore
import AppKitSystem
import SwiftUI

/// What most people come to settings for.
struct GeneralSettingsView: View {
    let launchAtLogin: LaunchAtLoginController
    let shortcuts: ShortcutsController

    @AppStorage(PasteMode.storageKey) private var pasteMode = PasteMode.direct.rawValue

    var body: some View {
        Form {
            Section {
                Toggle(isOn: launchAtLoginBinding) {
                    Text("Lancer AppKit à l’ouverture de session")
                    Text("Pour que vos copies soient gardées dès le démarrage du Mac.")
                }
                .accessibilityIdentifier("settings.launchAtLogin")

                if launchAtLogin.status == .requiresApproval {
                    LabeledContent {
                        Button("Ouvrir les Réglages Système", action: launchAtLogin.openSystemSettings)
                    } label: {
                        Text("En attente de votre accord dans les Réglages Système.")
                    }
                }
                if launchAtLogin.hasFailed {
                    Text("macOS a refusé ce changement. Réessayez depuis les Réglages Système.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                ShortcutRowView(
                    action: .openHistory,
                    shortcuts: shortcuts,
                    subtitle: "Les autres raccourcis sont dans la rubrique Raccourcis."
                )
            }
            Section {
                PasteModePickerView(selection: $pasteMode)
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: launchAtLogin.refresh)
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin.status != .disabled },
            set: { launchAtLogin.setEnabled($0) }
        )
    }
}
