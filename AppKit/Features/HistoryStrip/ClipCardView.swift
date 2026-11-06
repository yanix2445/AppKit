import AppKitCore
import SwiftUI

/// One copy in the strip.
struct ClipCardView: View {
    let clip: Clip
    let isSelected: Bool
    let appearance: SourceAppAppearance
    let thumbnailProvider: ClipThumbnailProvider

    private var title: String {
        switch clip.content {
        case .text: String(localized: "Texte brut")
        case .image: String(localized: "Image")
        case .pdf: String(localized: "PDF")
        }
    }

    private var format: String {
        switch clip.content {
        case .text:
            return String(localized: "Texte brut · \(clip.content.lineCount) lignes")
        case .image(let media):
            if let width = media.pixelWidth, let height = media.pixelHeight {
                return String(localized: "Image · \(width) × \(height) px")
            }
            return String(localized: "Image · \(size(of: media))")
        case .pdf(let media):
            if let pageCount = media.pageCount {
                return String(localized: "PDF · \(size(of: media)) · \(pageCount) pages")
            }
            return String(localized: "PDF · \(size(of: media))")
        }
    }

    private func size(of media: ClipMedia) -> String {
        Int64(media.byteCount).formatted(.byteCount(style: .file))
    }

    private var sourceName: String {
        clip.source?.name ?? String(localized: "App inconnue")
    }

    /// What VoiceOver reads of the content, which an image does not have in words.
    private var spokenContent: String {
        switch clip.content {
        case .text(let text): String(text.prefix(StripMetrics.previewCharacterLimit))
        case .image, .pdf: title
        }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: Motion.relativeDateRefresh)) { context in
            let date = clip.capturedAt.relativeDescription(relativeTo: context.date)

            VStack(alignment: .leading, spacing: 0) {
                ClipCardHeaderView(title: title, date: date, appearance: appearance)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                Text(format)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.xSmall)
            }
            .frame(width: StripMetrics.cardWidth, height: StripMetrics.cardHeight)
            .background(AppColor.cardFill)
            .clipShape(.rect(cornerRadius: CornerRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .strokeBorder(Color.accentColor, lineWidth: isSelected ? StripMetrics.selectionRingWidth : 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "\(format), \(sourceName), \(date), \(spokenContent)"))
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier("history.card")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch clip.content {
        case .text(let text):
            Text(verbatim: String(text.prefix(StripMetrics.previewCharacterLimit)))
                .font(.body)
                .lineLimit(StripMetrics.previewLineLimit)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.small)
        case .image(let media):
            ClipMediaPreviewView(id: clip.id, media: media, symbolName: "photo", contentMode: .fill, thumbnailProvider: thumbnailProvider)
        case .pdf(let media):
            ClipMediaPreviewView(id: clip.id, media: media, symbolName: "doc.richtext", contentMode: .fit, thumbnailProvider: thumbnailProvider)
        }
    }
}
