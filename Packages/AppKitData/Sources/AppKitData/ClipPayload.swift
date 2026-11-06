import AppKitCore

/// What is sealed for a copy: its content and the app it came from.
struct ClipPayload: Codable {
    let text: String
    let sourceName: String?
    let sourceBundleIdentifier: String?
    let mediaKind: String?
    let media: ClipMedia?

    private static let imageKind = "image"
    private static let pdfKind = "pdf"

    init(clip: Clip) {
        switch clip.content {
        case .text(let text):
            self.text = text
            mediaKind = nil
            media = nil
        case .image(let media):
            text = ""
            mediaKind = Self.imageKind
            self.media = media
        case .pdf(let media):
            text = ""
            mediaKind = Self.pdfKind
            self.media = media
        }
        sourceName = clip.source?.name
        sourceBundleIdentifier = clip.source?.bundleIdentifier
    }

    var content: ClipContent {
        switch (mediaKind, media) {
        case (Self.imageKind, let media?): .image(media)
        case (Self.pdfKind, let media?): .pdf(media)
        default: .text(text)
        }
    }

    var source: ClipSource? {
        sourceName.map { ClipSource(name: $0, bundleIdentifier: sourceBundleIdentifier) }
    }
}
