import AppKit

/// Asks what to do with a history whose key is missing. Nothing is erased without a confirmation.
@MainActor
final class HistoryRecoveryAlertPresenter {
    enum Choice {
        case retry
        case startOver
    }

    func askForChoice() -> Choice {
        NSApp.activate()
        while true {
            if runKeyMissingAlert() == .alertFirstButtonReturn {
                return .retry
            }
            if runStartOverConfirmation() == .alertSecondButtonReturn {
                return .startOver
            }
        }
    }

    private func runKeyMissingAlert() -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = String(localized: "Votre historique est chiffré avec une clé introuvable sur ce Mac")
        alert.informativeText = [
            String(localized: "AppKit n’a rien effacé. La clé est rangée dans le Trousseau de ce Mac : elle a peut-être été supprimée, ou pas encore restaurée."),
            String(localized: "En attendant, la capture est en pause : aucune copie n’est écrite en clair."),
        ].joined(separator: "\n\n")
        alert.addButton(withTitle: String(localized: "Réessayer"))
        alert.addButton(withTitle: String(localized: "Repartir à zéro…"))
        return alert.runModal()
    }

    private func runStartOverConfirmation() -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = String(localized: "Supprimer tout l’historique, épinglés compris ?")
        alert.informativeText = String(localized: "Sans sa clé, cet historique ne peut plus être lu. Sa suppression est définitive, même si la clé réapparaît ensuite.")
        alert.addButton(withTitle: String(localized: "Annuler"))
        let delete = alert.addButton(withTitle: String(localized: "Tout supprimer"))
        delete.hasDestructiveAction = true
        return alert.runModal()
    }
}
