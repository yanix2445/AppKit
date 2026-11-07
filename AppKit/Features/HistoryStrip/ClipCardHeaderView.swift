import SwiftUI

/// The colored top of a card: its type, its date and the icon of its source app.
struct ClipCardHeaderView: View {
    let title: String
    let date: String
    let appearance: SourceAppAppearance

    var body: some View {
        HStack(spacing: Spacing.small) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(appearance.prefersDarkText ? AppColor.onBrandDark : AppColor.onBrandLight)
                Text(date)
                    .font(.caption)
                    .foregroundStyle(appearance.prefersDarkText ? AppColor.onBrandDarkSecondary : AppColor.onBrandLightSecondary)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(nsImage: appearance.icon)
                .resizable()
                .frame(width: StripMetrics.sourceIconSize, height: StripMetrics.sourceIconSize)
                .accessibilityHidden(true)
        }
        .padding(.leading, Spacing.medium)
        .padding(.trailing, StripMetrics.cardHeaderTrailingInset)
        .frame(height: StripMetrics.cardHeaderHeight)
        .background(appearance.headerColor)
    }
}
