import AppKitCore
import SwiftUI

/// A swatch of the copied color, with its value on it.
struct ClipColorPreviewView: View {
    let color: ClipColor

    var body: some View {
        ZStack {
            Color(.sRGB, red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)
            Text(verbatim: color.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(.callout, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(StripMetrics.colorValueMinimumScale)
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.small)
                .background(.regularMaterial, in: .rect(cornerRadius: CornerRadius.control))
                .padding(Spacing.small)
        }
    }
}
