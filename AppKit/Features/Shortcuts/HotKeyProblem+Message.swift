import AppKitCore
import Foundation

extension HotKeyProblem {
    /// Says why, with the shortcut concerned, and what to do.
    func message(for combination: HotKeyCombination) -> String {
        let name = combination.displayName
        return switch self {
        case .needsGlobalModifier:
            String(localized: "Ce raccourci doit contenir ⌘, ⌃ ou ⌥ pour marcher depuis n’importe quelle app.")
        case .needsModifierOrSpecialKey:
            String(localized: "\(name) sert à écrire dans la recherche. Ajoutez ⌘, ⌃ ou ⌥.")
        case .reservedByMacOS:
            String(localized: "\(name) est réservé par macOS. Choisissez une autre combinaison.")
        case .reservedByStrip:
            String(localized: "\(name) sert déjà dans le bandeau. Choisissez une autre combinaison.")
        case .takenByAction(let action):
            String(localized: "\(name) sert déjà à : \(action.title). Choisissez une autre combinaison.")
        case .takenElsewhere:
            String(localized: "\(name) est déjà pris par macOS ou une autre app. Choisissez une autre combinaison.")
        }
    }
}
