import AppKitCore
import SwiftUI

/// What the strip shows before the first copy.
struct EmptyHistoryView: View {
    let openHotKey: HotKeyCombination?

    var body: some View {
        VStack(spacing: Spacing.small) {
            Text("Aucune copie pour l’instant")
                .font(.headline)
                .foregroundStyle(.primary)
            HStack(spacing: Spacing.xSmall) {
                KeyCapView(symbol: "⌘")
                KeyCapView(symbol: "C")
                Text("pour copier")
            }
            if let openHotKey {
                HStack(spacing: Spacing.xSmall) {
                    ForEach(openHotKey.symbols, id: \.self) { KeyCapView(symbol: $0) }
                    Text("pour rouvrir ce bandeau")
                }
            }
        }
        .font(.callout)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("history.empty")
    }
}
