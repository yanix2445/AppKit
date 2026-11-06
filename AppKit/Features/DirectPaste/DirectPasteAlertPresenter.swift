import AppKit

/// Says why direct paste needs the permission, once, when it first matters.
@MainActor
final class DirectPasteAlertPresenter {
    /// Returns `true` to open System Settings.
    func askToOpenSettings() -> Bool {
        NSApp.activate()
        let alert = NSAlert()
        alert.messageText = String(localized: "Autoriser le collage direct")
        alert.informativeText = [
            String(localized: "Pour coller directement dans l’app que vous utilisez, AppKit a besoin de la permission Accessibilité. Sans elle, l’élément sera simplement copié et vous ferez ⌘V."),
            String(localized: "Réglages Système › Confidentialité et sécurité › Accessibilité"),
        ].joined(separator: "\n\n")
        alert.addButton(withTitle: String(localized: "Ouvrir les Réglages"))
        alert.addButton(withTitle: String(localized: "Plus tard"))
        return alert.runModal() == .alertFirstButtonReturn
    }
}
