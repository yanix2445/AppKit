import SwiftUI

/// One category in the toolbar of the strip.
struct HistoryStripFilterChip: View {
    let title: String
    let isSelected: Bool
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.callout)
                .foregroundStyle(isSelected ? AppColor.onBrandLight : .primary)
                .padding(.horizontal, Spacing.medium)
                .frame(height: StripMetrics.toolbarHeight)
                .background(isSelected ? Color.accentColor : AppColor.controlFill, in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .fixedSize()
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(identifier)
    }
}
