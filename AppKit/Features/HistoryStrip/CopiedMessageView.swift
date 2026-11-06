import SwiftUI

/// The brief message shown once a copy is back on the pasteboard.
struct CopiedMessageView: View {
    var body: some View {
        HStack(spacing: Spacing.xSmall) {
            Text("Copié · faites")
                .font(.callout.weight(.semibold))
            KeyCapView(symbol: "⌘")
            KeyCapView(symbol: "V")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular, in: .capsule)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Copié · faites ⌘V")
        .accessibilityIdentifier("history.copiedMessage")
    }
}
