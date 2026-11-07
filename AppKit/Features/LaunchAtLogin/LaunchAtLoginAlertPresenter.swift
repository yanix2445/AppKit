import AppKit

/// Offers to start at login, with the reason.
@MainActor
final class LaunchAtLoginAlertPresenter {
    func askToEnable() -> Bool {
        NSApp.activate()
        let alert = NSAlert()
        alert.messageText = String(localized: "Lancer AppKit à l’ouverture de session ?")
        alert.informativeText = String(localized: "Pour ne rater aucune copie après un redémarrage. Vous pourrez changer d’avis dans les Réglages.")
        alert.addButton(withTitle: String(localized: "Activer"))
        alert.addButton(withTitle: String(localized: "Plus tard"))
        return alert.runModal() == .alertFirstButtonReturn
    }
}
