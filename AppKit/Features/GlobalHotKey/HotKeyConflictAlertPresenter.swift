import AppKit
import AppKitCore
import SwiftUI

/// Tells that a shortcut is taken and offers the first free one.
@MainActor
final class HotKeyConflictAlertPresenter {
    func askForFallback(taken: HotKeyCombination, fallbacks: [HotKeyFallback]) -> HotKeyCombination? {
        NSApp.activate()
        let suggestion = fallbacks.first(where: \.isAvailable)?.combination

        let alert = NSAlert()
        alert.messageText = String(localized: "\(taken.displayName) est déjà utilisé par une autre app")
        alert.informativeText = String(localized: "Choisissez un autre raccourci pour ouvrir l’historique.")
        let list = NSHostingView(rootView: HotKeyFallbackListView(fallbacks: fallbacks))
        list.frame.size = list.fittingSize
        alert.accessoryView = list
        if let suggestion {
            alert.addButton(withTitle: String(localized: "Utiliser \(suggestion.displayName)"))
        }
        alert.addButton(withTitle: String(localized: "Plus tard"))

        let response = alert.runModal()
        return response == .alertFirstButtonReturn ? suggestion : nil
    }
}
