import SwiftUI

/// The brief message shown once a copy is back on the pasteboard.
struct CopiedMessageView: View {
    let onEnableDirectPaste: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.small) {
            HStack(spacing: Spacing.xSmall) {
                Text("Copié · faites")
                    .font(.callout.weight(.semibold))
                KeyCapView(symbol: "⌘")
                KeyCapView(symbol: "V")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Copié · faites ⌘V")

            if let onEnableDirectPaste {
                Button("Activer le collage direct", action: onEnableDirectPaste)
                    .buttonStyle(.link)
                    .font(.callout)
                    .accessibilityIdentifier("history.enableDirectPaste")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular, in: .capsule)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("history.copiedMessage")
    }
}
