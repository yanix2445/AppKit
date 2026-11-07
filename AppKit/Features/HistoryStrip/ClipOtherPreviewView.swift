import AppKit
import SwiftUI

/// A copy that only its app can read: it has nothing to show but that app.
struct ClipOtherPreviewView: View {
    let name: String
    let icon: NSImage

    var body: some View {
        VStack(spacing: Spacing.small) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: StripMetrics.filePreviewIconSize, height: StripMetrics.filePreviewIconSize)
                .accessibilityHidden(true)
            Text(verbatim: name)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, Spacing.medium)
    }
}
