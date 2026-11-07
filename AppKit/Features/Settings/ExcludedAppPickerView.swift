import AppKit
import AppKitCore
import SwiftUI

/// Chooses an app to exclude among those installed on this Mac.
struct ExcludedAppPickerView: View {
    let alreadyExcluded: Set<String>
    let onExclude: (ClipExcludedApp) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var apps: [ClipExcludedApp] = []
    @State private var query = ""
    @State private var selection: ClipExcludedApp.ID?

    private var visibleApps: [ClipExcludedApp] {
        apps.filter { !alreadyExcluded.contains($0.bundleIdentifier) && (query.isEmpty || $0.name.localizedStandardContains(query)) }
    }

    private var selected: ClipExcludedApp? {
        apps.first { $0.id == selection }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Exclure une app")
                .font(.headline)
            Text("Ce que vous copiez dans cette app ne sera jamais gardé.")
                .foregroundStyle(.secondary)
            TextField("Rechercher une app", text: $query)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("settings.appPickerSearch")
            List(visibleApps, selection: $selection) { app in
                Text(verbatim: app.name)
                    .tag(app.id)
                    .accessibilityIdentifier("settings.appPicker.\(app.bundleIdentifier)")
            }
            .frame(height: SettingsMetrics.appPickerListHeight)
            .accessibilityIdentifier("settings.appPicker")
            HStack {
                Spacer()
                Button("Annuler", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button {
                    if let selected {
                        onExclude(selected)
                        dismiss()
                    }
                } label: {
                    Text(selected.map { String(localized: "Exclure \($0.name)") } ?? String(localized: "Exclure"))
                }
                .keyboardShortcut(.defaultAction)
                .disabled(selected == nil)
                .accessibilityIdentifier("settings.appPickerConfirm")
            }
        }
        .padding(Spacing.large)
        .frame(width: SettingsMetrics.appPickerWidth)
        .task { apps = await Self.installedApps() }
    }

    private static func installedApps() async -> [ClipExcludedApp] {
        await Task.detached { scanInstalledApps() }.value
    }

    /// Goes one folder deep, for the suites and for Utilities.
    private nonisolated static func scanInstalledApps() -> [ClipExcludedApp] {
        let manager = FileManager.default
        let folders = [
            "/Applications",
            "/System/Applications",
            "/System/Library/CoreServices/Applications",
            NSHomeDirectory() + "/Applications",
        ]
        var found: [String: ClipExcludedApp] = [:]
        for folder in folders {
            let enumerator = manager.enumerator(
                at: URL(fileURLWithPath: folder),
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )
            while let url = enumerator?.nextObject() as? URL {
                if (enumerator?.level ?? 0) >= 2 {
                    enumerator?.skipDescendants()
                }
                guard url.pathExtension == "app", let identifier = Bundle(url: url)?.bundleIdentifier else { continue }
                let name = (manager.displayName(atPath: url.path) as NSString).deletingPathExtension
                found[identifier] = ClipExcludedApp(bundleIdentifier: identifier, name: name)
            }
        }
        return found.values.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
