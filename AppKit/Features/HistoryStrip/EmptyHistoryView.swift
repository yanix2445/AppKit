import SwiftUI

/// What the strip shows before the first copy.
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: Spacing.small) {
            Text("Aucune copie pour l’instant")
                .font(.headline)
            HStack(spacing: Spacing.xSmall) {
                KeyCapView(symbol: "⌘")
                KeyCapView(symbol: "C")
                Text("pour copier")
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("history.empty")
    }
}
