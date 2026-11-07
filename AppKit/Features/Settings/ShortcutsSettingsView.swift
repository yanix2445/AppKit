import AppKitCore
import SwiftUI

/// Every shortcut of AppKit.
struct ShortcutsSettingsView: View {
    let shortcuts: ShortcutsController

    var body: some View {
        Form {
            Section("Depuis n’importe quelle app") {
                ForEach(HotKeyAction.allCases.filter(\.isGlobal), id: \.self) { action in
                    ShortcutRowView(action: action, shortcuts: shortcuts)
                }
            }
            Section("Dans le bandeau") {
                ForEach(HotKeyAction.allCases.filter { !$0.isGlobal }, id: \.self) { action in
                    ShortcutRowView(action: action, shortcuts: shortcuts)
                }
            }
            Section {
                LabeledContent {
                    Button("Tout rétablir") { shortcuts.resetAll() }
                        .accessibilityIdentifier("settings.shortcutsResetAll")
                } label: {
                    Text("Raccourcis par défaut")
                    Text("Échap annule l’enregistrement en cours.")
                }
            }
        }
        .formStyle(.grouped)
    }
}
