import SwiftUI

/// A short word on a card about where a copy comes from or how long it stays.
struct ClipBadgeView: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xxSmall)
            .background(.regularMaterial, in: .capsule)
            .padding(Spacing.small)
    }
}
