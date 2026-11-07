import AppKitCore
import Foundation
import SwiftUI

/// One copy in the strip.
struct ClipCardView: View {
    let clip: Clip
    let isSelected: Bool
    let appearance: SourceAppAppearance
    let thumbnailProvider: ClipThumbnailProvider

    @State private var isHovered = false
    @State private var fileSize: Int64?
    @AppStorage(ProtectedFolderConsent.anyGrantedKey) private var consentRevision = 0

    private var title: String {
        switch clip.content {
        case .text: String(localized: "Texte brut")
        case .richText: String(localized: "Texte enrichi")
        case .link: String(localized: "Lien")
        case .color: String(localized: "Couleur")
        case .image: String(localized: "Image")
        case .pdf: String(localized: "PDF")
        case .files(let files): files.count == 1 ? String(localized: "Fichier") : String(localized: "Fichiers")
        case .other: String(localized: "Autre")
        }
    }

    private var format: String {
        switch clip.content {
        case .text:
            return String(localized: "Texte brut · \(clip.content.lineCount) lignes")
        case .richText:
            return String(localized: "Texte enrichi · \(clip.content.lineCount) lignes")
        case .link:
            return String(localized: "Lien")
        case .color(let color):
            return color.text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#")
                ? String(localized: "Couleur · HEX")
                : String(localized: "Couleur")
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
        case .files(let files):
            guard files.count == 1 else { return String(localized: "\(files.count) fichiers") }
            let kind = files[0].fileExtension.uppercased()
            return fileSize.map { "\(kind) · \($0.formatted(.byteCount(style: .file)))" } ?? kind
        case .other:
            return String(localized: "Se recolle dans \(sourceName)")
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
        case .text(let text), .richText(let text), .link(let text): String(text.prefix(StripMetrics.previewCharacterLimit))
        case .color(let color): color.text
        case .image, .pdf: title
        case .files(let files): files.map(\.name).joined(separator: ", ")
        case .other: String(localized: "Élément \(sourceName)")
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
                    .padding(.bottom, StripMetrics.cardFooterBottomInset)
                    .frame(height: StripMetrics.cardFooterHeight, alignment: .bottom)
            }
            .frame(width: StripMetrics.cardWidth, height: StripMetrics.cardHeight)
            .background(AppColor.cardFill)
            .clipShape(.rect(cornerRadius: CornerRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .strokeBorder(
                        isSelected || isHovered ? Color.accentColor : .clear,
                        lineWidth: isSelected ? StripMetrics.selectionRingWidth : StripMetrics.hoverRingWidth
                    )
            }
            .shadow(color: AppColor.cardShadow, radius: StripMetrics.cardShadowRadius, y: StripMetrics.cardShadowOffset)
            .onHover { isHovered = $0 }
            .task(id: consentRevision) { readFileSize() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "\(format), \(sourceName), \(date), \(spokenContent)"))
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier("history.card")
        }
    }

    /// Reads nothing in a protected folder before the user has agreed.
    private func readFileSize() {
        guard case .files(let files) = clip.content, files.count == 1,
              ProtectedFolderConsent.allowsReading(files[0].path)
        else { return }
        let attributes = try? FileManager.default.attributesOfItem(atPath: files[0].path)
        fileSize = (attributes?[.size] as? NSNumber)?.int64Value
    }

    private func textPreview(_ text: String) -> some View {
        Text(verbatim: String(text.prefix(StripMetrics.previewCharacterLimit)))
            .font(.body)
            .lineLimit(StripMetrics.previewLineLimit)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, Spacing.medium)
            .padding(.top, StripMetrics.cardPreviewTopInset)
            .padding(.bottom, StripMetrics.cardPreviewBottomInset)
    }

    @ViewBuilder
    private var content: some View {
        switch clip.content {
        case .text(let text), .richText(let text):
            textPreview(text)
        case .link(let address):
            textPreview(address.trimmingCharacters(in: .whitespacesAndNewlines))
                .foregroundStyle(Color.accentColor)
        case .color(let color):
            ClipColorPreviewView(color: color)
        case .image(let media):
            ClipMediaPreviewView(id: clip.id, media: media, symbolName: "photo", contentMode: .fill, thumbnailProvider: thumbnailProvider)
        case .pdf(let media):
            ClipMediaPreviewView(id: clip.id, media: media, symbolName: "doc.richtext", contentMode: .fit, thumbnailProvider: thumbnailProvider)
        case .files(let files):
            ClipFilesPreviewView(files: files)
        case .other:
            ClipOtherPreviewView(name: String(localized: "Élément \(sourceName)"), icon: appearance.icon)
        }
    }
}
