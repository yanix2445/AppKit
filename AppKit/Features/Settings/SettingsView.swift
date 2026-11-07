import AppKitCore
import SwiftUI

/// The settings: pages in a sidebar, and a search that leads to any setting.
struct SettingsView: View {
    let navigation: SettingsNavigation
    let launchAtLogin: LaunchAtLoginController
    let shortcuts: ShortcutsController
    let permissions: PermissionsController
    let storage: StorageSettingsViewModel
    let defaults: UserDefaults
    let feedback: CopyFeedbackController
    let showOnboarding: () -> Void

    private var selection: Binding<SettingsPane?> {
        Binding(
            get: { navigation.isSearching ? nil : navigation.pane },
            set: { if let pane = $0 { navigation.show(pane) } }
        )
    }

    private var query: Binding<String> {
        Binding(get: { navigation.query }, set: { navigation.query = $0 })
    }

    var body: some View {
        NavigationSplitView {
            List(selection: selection) {
                Section {
                    row(.general)
                    row(.shortcuts)
                    row(.sounds)
                }
                Section {
                    row(.privacy)
                    row(.storage)
                    row(.permissions)
                }
            }
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(SettingsMetrics.sidebarWidth)
        } detail: {
            detail
                .navigationTitle(navigation.isSearching ? String(localized: "Réglages") : navigation.pane.title)
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button("Précédent", systemImage: "chevron.left", action: navigation.goBack)
                            .disabled(!navigation.canGoBack)
                            .accessibilityIdentifier("settings.back")
                        Button("Suivant", systemImage: "chevron.right", action: navigation.goForward)
                            .disabled(!navigation.canGoForward)
                            .accessibilityIdentifier("settings.forward")
                    }
                }
        }
        .searchable(text: query, placement: .sidebar, prompt: Text("Rechercher dans les réglages…"))
        .navigationSplitViewStyle(.balanced)
        .frame(
            minWidth: SettingsMetrics.minimumWidth,
            idealWidth: SettingsMetrics.width,
            minHeight: SettingsMetrics.minimumHeight,
            idealHeight: SettingsMetrics.height
        )
    }

    private func row(_ pane: SettingsPane) -> some View {
        Label {
            Text(verbatim: pane.title)
        } icon: {
            SettingsPaneIconView(pane: pane)
        }
        .tag(pane)
        .accessibilityIdentifier("settings.pane.\(pane.rawValue)")
    }

    @ViewBuilder
    private var detail: some View {
        if navigation.isSearching {
            SettingsSearchResultsView(navigation: navigation)
        } else {
            switch navigation.pane {
            case .general:
                GeneralSettingsView(launchAtLogin: launchAtLogin, shortcuts: shortcuts, showOnboarding: showOnboarding)
            case .shortcuts:
                ShortcutsSettingsView(shortcuts: shortcuts)
            case .sounds:
                Form { SoundSettingsSection(feedback: feedback) }.formStyle(.grouped)
            case .privacy:
                Form { PrivacySettingsSection(defaults: defaults) }.formStyle(.grouped)
            case .storage:
                Form { StorageSettingsSection(viewModel: storage) }.formStyle(.grouped)
            case .permissions:
                PermissionsSettingsView(permissions: permissions)
            }
        }
    }
}
