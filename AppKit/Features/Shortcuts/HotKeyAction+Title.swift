import AppKitCore
import Foundation

extension HotKeyAction {
    var title: String {
        switch self {
        case .openHistory: String(localized: "Ouvrir l’historique")
        case .togglePause: String(localized: "Mettre en pause ou reprendre la capture")
        case .paste: String(localized: "Coller")
        case .pastePlainText: String(localized: "Coller en texte brut")
        case .delete: String(localized: "Supprimer")
        case .togglePin: String(localized: "Épingler ou désépingler")
        case .movePinnedLeft: String(localized: "Déplacer un épinglé à gauche")
        case .movePinnedRight: String(localized: "Déplacer un épinglé à droite")
        }
    }
}
