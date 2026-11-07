import Foundation

/// A setting the search can lead to.
struct SettingsSearchEntry: Identifiable {
    let title: String
    let pane: SettingsPane

    var id: String { "\(pane.rawValue).\(title)" }

    static var all: [SettingsSearchEntry] {
        [
            SettingsSearchEntry(title: String(localized: "Lancer AppKit à l’ouverture de session"), pane: .general),
            SettingsSearchEntry(title: String(localized: "Mode de collage"), pane: .general),
            SettingsSearchEntry(title: String(localized: "Ouvrir l’historique"), pane: .shortcuts),
            SettingsSearchEntry(title: String(localized: "Mettre en pause ou reprendre la capture"), pane: .shortcuts),
            SettingsSearchEntry(title: String(localized: "Coller en texte brut"), pane: .shortcuts),
            SettingsSearchEntry(title: String(localized: "Épingler ou désépingler"), pane: .shortcuts),
            SettingsSearchEntry(title: String(localized: "Copie gardée"), pane: .sounds),
            SettingsSearchEntry(title: String(localized: "Copie écartée"), pane: .sounds),
            SettingsSearchEntry(title: String(localized: "Effets sonores de macOS"), pane: .sounds),
            SettingsSearchEntry(title: String(localized: "Garder les copies générées automatiquement"), pane: .privacy),
            SettingsSearchEntry(title: String(localized: "Mots de passe et copies confidentielles"), pane: .privacy),
            SettingsSearchEntry(title: String(localized: "Catégories exclues"), pane: .privacy),
            SettingsSearchEntry(title: String(localized: "Apps exclues"), pane: .privacy),
            SettingsSearchEntry(title: String(localized: "Durée de conservation"), pane: .storage),
            SettingsSearchEntry(title: String(localized: "Copies volumineuses"), pane: .storage),
            SettingsSearchEntry(title: String(localized: "Effacer tout l’historique"), pane: .storage),
            SettingsSearchEntry(title: String(localized: "Accès au presse-papiers"), pane: .permissions),
            SettingsSearchEntry(title: String(localized: "Accessibilité"), pane: .permissions),
            SettingsSearchEntry(title: String(localized: "Ouverture de session"), pane: .permissions),
        ]
    }
}
