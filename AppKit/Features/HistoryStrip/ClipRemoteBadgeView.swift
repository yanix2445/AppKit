import SwiftUI

/// Tells that a copy came from another device. macOS does not say which one.
struct ClipRemoteBadgeView: View {
    var body: some View {
        Text("Autre appareil")
            .font(.caption)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xxSmall)
            .background(.regularMaterial, in: .capsule)
            .padding(Spacing.small)
            .accessibilityHidden(true)
    }
}
