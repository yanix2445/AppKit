import SwiftUI

/// The keys of a shortcut, large enough to read at a glance.
struct OnboardingKeysView: View {
    let symbols: [String]

    var body: some View {
        HStack(spacing: Spacing.small) {
            ForEach(symbols, id: \.self) { symbol in
                Text(verbatim: symbol)
                    .font(.title2.weight(.semibold))
                    .frame(width: OnboardingMetrics.keySize, height: OnboardingMetrics.keySize)
                    .background(.background, in: .rect(cornerRadius: CornerRadius.control))
                    .shadow(color: AppColor.cardShadow, radius: StripMetrics.cardShadowRadius, y: StripMetrics.cardShadowOffset)
            }
        }
    }
}
