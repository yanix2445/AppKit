import AppKitCore
import SwiftUI

/// What the strip says when a search or a filter finds nothing.
struct NoResultsView: View {
    let viewModel: HistoryStripViewModel

    private var title: String {
        if viewModel.isSearching {
            return String(localized: "Aucun résultat pour « \(viewModel.query) »")
        }
        return String(localized: "Aucune copie dans cette catégorie")
    }

    private var message: String? {
        guard viewModel.isSearching else { return nil }
        if let category = viewModel.category {
            return String(localized: "Rien dans la catégorie \(category.title). Essayez d’autres mots, ou cherchez dans toutes les catégories.")
        }
        return String(localized: "Essayez d’autres mots.")
    }

    var body: some View {
        VStack(spacing: Spacing.small) {
            Text(verbatim: title)
                .font(.headline)
            if let message {
                Text(verbatim: message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            if viewModel.category != nil {
                Button(viewModel.isSearching ? "Chercher dans toutes les catégories" : "Voir toutes les copies") {
                    viewModel.setCategory(nil)
                }
                .accessibilityIdentifier("history.allCategories")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("history.noResults")
    }
}
