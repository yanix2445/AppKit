import AppKit
import Foundation

/// Explains the pasteboard before macOS asks, and says what stops working when it refuses.
@MainActor
final class ClipboardAccessAlertPresenter {
    /// - Returns: whether the user wants to go on.
    func explainReading() -> Bool {
        NSApp.activate()
        let alert = NSAlert()
        alert.messageText = String(localized: "AppKit va lire votre presse-papiers")
        alert.informativeText = String(localized: "Pour garder l’historique de ce que vous copiez, AppKit lit le presse-papiers à chaque copie. macOS va vous demander votre accord. Rien ne quitte ce Mac. Les mots de passe et les copies confidentielles ne sont jamais gardés.")
        alert.addButton(withTitle: String(localized: "Continuer"))
        alert.addButton(withTitle: String(localized: "Pas maintenant"))
        return runInFront(alert)
    }

    /// - Returns: whether the user wants to open System Settings.
    func explainRefusal() -> Bool {
        NSApp.activate()
        let alert = NSAlert()
        alert.messageText = String(localized: "AppKit ne peut pas lire le presse-papiers")
        alert.informativeText = String(localized: "Sans cet accès, vos copies ne sont pas gardées et le bandeau reste vide. Réglages Système › Confidentialité et sécurité")
        alert.addButton(withTitle: String(localized: "Ouvrir les Réglages Système"))
        alert.addButton(withTitle: String(localized: "Plus tard"))
        return runInFront(alert)
    }

    /// At launch, macOS may leave a menu bar app behind the app in use: the explanation must show.
    private func runInFront(_ alert: NSAlert) -> Bool {
        alert.window.level = .floating
        return alert.runModal() == .alertFirstButtonReturn
    }
}
