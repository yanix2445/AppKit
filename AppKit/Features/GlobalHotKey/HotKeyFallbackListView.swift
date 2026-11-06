import AppKitCore
import SwiftUI

/// The shortcuts on offer, each with its state, above the reminder that the icon still works.
struct HotKeyFallbackListView: View {
    let fallbacks: [HotKeyFallback]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            ForEach(fallbacks, id: \.combination) { fallback in
                HStack(spacing: Spacing.xSmall) {
                    ForEach(fallback.combination.symbols, id: \.self) { KeyCapView(symbol: $0) }
                    Spacer()
                    Text(fallback.isAvailable ? "Libre" : "Déjà pris")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(fallback.combination.displayName), \(fallback.isAvailable ? String(localized: "Libre") : String(localized: "Déjà pris"))")
            }
            Text("Le bandeau reste accessible par l’icône de la barre de menus.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: AlertMetrics.accessoryWidth)
    }
}
