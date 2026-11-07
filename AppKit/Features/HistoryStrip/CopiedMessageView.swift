import SwiftUI

/// The brief message shown after choosing a copy.
struct CopiedMessageView: View {
    enum Content {
        case copied(onEnableDirectPaste: (() -> Void)?)
        case failure(String)
    }

    let content: Content

    var body: some View {
        HStack(spacing: Spacing.small) {
            switch content {
            case .copied(let onEnableDirectPaste):
                copied
                if let onEnableDirectPaste {
                    Button("Activer le collage direct", action: onEnableDirectPaste)
                        .buttonStyle(.link)
                        .font(.callout)
                        .accessibilityIdentifier("history.enableDirectPaste")
                }
            case .failure(let text):
                Image(systemName: "exclamationmark.triangle")
                    .accessibilityHidden(true)
                Text(verbatim: text)
                    .font(.callout.weight(.semibold))
                    .accessibilityIdentifier("history.failureMessage")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular, in: .capsule)
        .clipShape(.capsule)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("history.copiedMessage")
    }

    private var copied: some View {
        HStack(spacing: Spacing.xSmall) {
            Text("Copié · faites")
                .font(.callout.weight(.semibold))
            KeyCapView(symbol: "⌘")
            KeyCapView(symbol: "V")
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Copié · faites ⌘V")
    }
}
