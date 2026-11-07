import SwiftUI

/// A permission, what stops working without it, its state, and the way to change it.
struct PermissionRowView: View {
    let identifier: String
    let title: LocalizedStringKey
    let consequence: LocalizedStringKey
    let status: PermissionStatus
    let openSettings: () -> Void

    private var color: Color {
        switch status {
        case .granted: .green
        case .toGrant: .orange
        case .denied: .red
        }
    }

    var body: some View {
        LabeledContent {
            HStack(spacing: Spacing.small) {
                HStack(spacing: Spacing.xSmall) {
                    Circle()
                        .fill(color)
                        .frame(width: Spacing.small, height: Spacing.small)
                        .accessibilityHidden(true)
                    Text(verbatim: status.title)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("settings.permission.\(identifier)")
                }
                if status != .granted {
                    Button("Ouvrir le réglage", action: openSettings)
                        .accessibilityLabel(Text("Ouvrir le réglage : \(Text(title))"))
                        .accessibilityIdentifier("settings.permissionOpen.\(identifier)")
                }
            }
        } label: {
            Text(title)
            Text(consequence)
        }
    }
}
