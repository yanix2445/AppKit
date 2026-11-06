import AppKitCore

/// What is sealed for a copy: its content and the app it came from.
struct ClipPayload: Codable {
    let text: String
    let sourceName: String?
    let sourceBundleIdentifier: String?
    let mediaKind: String?
    let media: ClipMedia?
    let textKind: String?
    let color: ClipColor?

    private static let imageKind = "image"
    private static let pdfKind = "pdf"
    private static let richTextKind = "richText"
    private static let linkKind = "link"

    init(clip: Clip) {
        text = clip.content.plainText ?? ""
        switch clip.content {
        case .richText: textKind = Self.richTextKind
        case .link: textKind = Self.linkKind
        case .text, .color, .image, .pdf: textKind = nil
        }
        switch clip.content {
        case .color(let color): self.color = color
        case .text, .richText, .link, .image, .pdf: color = nil
        }
        switch clip.content {
        case .image(let media):
            mediaKind = Self.imageKind
            self.media = media
        case .pdf(let media):
            mediaKind = Self.pdfKind
            self.media = media
        case .text, .richText, .link, .color:
            mediaKind = nil
            media = nil
        }
        sourceName = clip.source?.name
        sourceBundleIdentifier = clip.source?.bundleIdentifier
    }

    var content: ClipContent {
        if let color { return .color(color) }
        switch (mediaKind, media) {
        case (Self.imageKind, let media?): return .image(media)
        case (Self.pdfKind, let media?): return .pdf(media)
        default: break
        }
        switch textKind {
        case Self.richTextKind: return .richText(text)
        case Self.linkKind: return .link(text)
        default: return .text(text)
        }
    }

    var source: ClipSource? {
        sourceName.map { ClipSource(name: $0, bundleIdentifier: sourceBundleIdentifier) }
    }
}
