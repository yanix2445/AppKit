import SwiftUI

/// What AppKit needs from macOS, and what stops working without it.
struct PermissionsSettingsView: View {
    let permissions: PermissionsController

    var body: some View {
        Form {
            Section {
                PermissionRowView(
                    identifier: "clipboard",
                    title: "Accès au presse-papiers",
                    consequence: "Sans lui, vos copies ne sont pas gardées et le bandeau reste vide.",
                    status: permissions.clipboardStatus,
                    openSettings: permissions.openClipboardSettings
                )
                PermissionRowView(
                    identifier: "accessibility",
                    title: "Accessibilité",
                    consequence: "Sans elle, l’élément est copié et vous faites ⌘V.",
                    status: permissions.accessibilityStatus,
                    openSettings: permissions.openAccessibilitySettings
                )
                PermissionRowView(
                    identifier: "launchAtLogin",
                    title: "Ouverture de session",
                    consequence: "Sans elle, AppKit ne se lance pas seul au démarrage du Mac.",
                    status: permissions.launchAtLoginStatus,
                    openSettings: permissions.openLaunchAtLoginSettings
                )
            }
            Section {
                LabeledContent {
                    EmptyView()
                } label: {
                    Text("Mise à jour de l’état")
                    Text("L’état se met à jour à l’ouverture des Réglages et à votre retour de Réglages Système.")
                }
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: permissions.refresh)
    }
}
