import SwiftUI

/// The explanation of pasting, above the selected card.
struct SelectedCardTip: ViewModifier {
    let isSelected: Bool
    let viewModel: HistoryStripViewModel

    @ViewBuilder
    func body(content: Content) -> some View {
        if isSelected {
            content.historyStripTip(.paste, viewModel: viewModel)
        } else {
            content
        }
    }
}
