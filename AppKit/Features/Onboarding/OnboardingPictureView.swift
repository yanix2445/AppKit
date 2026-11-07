import AppKit
import AppKitCore
import SwiftUI

/// What each step shows, made of the real cards of the strip. It says nothing that the text does not.
struct OnboardingPictureView: View {
    let step: OnboardingStep
    let openHistory: HotKeyCombination?
    let paste: HotKeyCombination?

    private let appearanceProvider = SourceAppAppearanceProvider()
    private let thumbnails = ClipThumbnailProvider(load: { _ in nil })

    /// Read from the bundle: an app icon set cannot be loaded by name from the asset catalog.
    private static let appIcon = Bundle.main.image(forResource: "AppIcon")

    private static let sampleText = String(localized: "Décisions\n• Conserver le bandeau aéré.\n• Distinguer le type et le format.")

    var body: some View {
        Group {
            switch step {
            case .welcome:
                if let icon = Self.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: OnboardingMetrics.iconSize, height: OnboardingMetrics.iconSize)
                }
            case .reopen:
                HStack(spacing: Spacing.medium) {
                    if let openHistory {
                        OnboardingKeysView(symbols: openHistory.symbols)
                        Text("puis")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    if let paste {
                        OnboardingKeysView(symbols: paste.symbols)
                    }
                }
            case .find:
                VStack(spacing: Spacing.small) {
                    HStack(spacing: Spacing.small) {
                        Image(systemName: "magnifyingglass")
                        Text(verbatim: "decisions")
                        Spacer()
                        Text("1 résultat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, Spacing.small)
                    .frame(width: StripMetrics.searchFieldWidth, height: StripMetrics.toolbarHeight)
                    .background(AppColor.controlFill, in: .rect(cornerRadius: CornerRadius.control))
                    .overlay {
                        RoundedRectangle(cornerRadius: CornerRadius.control)
                            .strokeBorder(Color.accentColor, lineWidth: StripMetrics.focusRingWidth)
                    }
                    card(.richText(Self.sampleText), highlighted: ["decisions"], isSelected: true)
                }
            case .pin:
                HStack(spacing: Spacing.small) {
                    card(.text(Self.sampleText), isPinned: true)
                    card(.color(ClipColor(red: 0.23, green: 0.51, blue: 0.96, text: "#3B82F6")), isPinned: true)
                }
                .padding(StripMetrics.pinnedSectionInset)
                .background(AppColor.controlFill, in: .rect(cornerRadius: CornerRadius.group))
            case .ready:
                VStack(spacing: Spacing.medium) {
                    if let openHistory {
                        OnboardingKeysView(symbols: openHistory.symbols)
                    }
                    Label("Vos copies restent sur ce Mac, chiffrées.", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.controlFill)
        // A picture: the text below says the same.
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private func card(
        _ content: ClipContent,
        highlighted: [String] = [],
        isSelected: Bool = false,
        isPinned: Bool = false
    ) -> some View {
        ClipCardView(
            clip: Clip(content: content, source: nil, capturedAt: .now, isPinned: isPinned),
            isSelected: isSelected,
            highlightedWords: highlighted,
            appearance: appearanceProvider.appearance(forBundleIdentifier: Bundle.main.bundleIdentifier),
            thumbnailProvider: thumbnails
        )
    }
}
