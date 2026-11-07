import AppKitCore
import Foundation

extension ClipCategory {
    /// Its name in the filters and the exclusions.
    var title: String {
        switch self {
        case .text: String(localized: "Texte")
        case .richText: String(localized: "Texte enrichi")
        case .link: String(localized: "Lien")
        case .image: String(localized: "Image")
        case .files: String(localized: "Fichiers")
        case .color: String(localized: "Couleur")
        case .pdf: String(localized: "PDF")
        case .other: String(localized: "Autre")
        }
    }
}
