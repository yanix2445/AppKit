import AppKitCore
import SwiftUI

/// One copy in the strip.
struct ClipCardView: View {
    let clip: Clip
    let isSelected: Bool
    let appearance: SourceAppAppearance

    private var text: String {
        switch clip.content {
        case .text(let text): String(text.prefix(StripMetrics.previewCharacterLimit))
        }
    }

    private var format: String {
        String(localized: "Texte brut · \(clip.content.lineCount) lignes")
    }

    private var sourceName: String {
        clip.source?.name ?? String(localized: "App inconnue")
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: Motion.relativeDateRefresh)) { context in
            let date = clip.capturedAt.relativeDescription(relativeTo: context.date)

            VStack(alignment: .leading, spacing: 0) {
                ClipCardHeaderView(title: String(localized: "Texte brut"), date: date, appearance: appearance)

                Text(verbatim: text)
                    .font(.body)
                    .lineLimit(StripMetrics.previewLineLimit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.top, Spacing.small)

                Text(format)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.bottom, Spacing.small)
            }
            .frame(width: StripMetrics.cardWidth, height: StripMetrics.cardHeight)
            .background(AppColor.cardFill)
            .clipShape(.rect(cornerRadius: CornerRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .strokeBorder(Color.accentColor, lineWidth: isSelected ? StripMetrics.selectionRingWidth : 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "\(format), \(sourceName), \(date), \(text)"))
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier("history.card")
        }
    }
}
