import AppKitCore
import Foundation

/// What is sealed for a copy: its content and the app it came from.
struct ClipPayload: Codable {
    let text: String
    let sourceName: String?
    let sourceBundleIdentifier: String?
    let mediaKind: String?
    let media: ClipMedia?
    let textKind: String?
    let color: ClipColor?
    let files: [ClipFile]?
    let firstCapturedAt: Date?
    let copyCount: Int?
    let fingerprint: Data?
    let isRemote: Bool?

    private static let imageKind = "image"
    private static let pdfKind = "pdf"
    private static let richTextKind = "richText"
    private static let linkKind = "link"
    private static let otherKind = "other"

    init(clip: Clip) {
        text = clip.content.plainText ?? ""
        switch clip.content {
        case .richText: textKind = Self.richTextKind
        case .link: textKind = Self.linkKind
        case .other: textKind = Self.otherKind
        case .text, .color, .image, .pdf, .files: textKind = nil
        }
        switch clip.content {
        case .color(let color): self.color = color
        case .text, .richText, .link, .image, .pdf, .files, .other: color = nil
        }
        switch clip.content {
        case .image(let media):
            mediaKind = Self.imageKind
            self.media = media
        case .pdf(let media):
            mediaKind = Self.pdfKind
            self.media = media
        case .text, .richText, .link, .color, .files, .other:
            mediaKind = nil
            media = nil
        }
        if case .files(let files) = clip.content {
            self.files = files
        } else {
            files = nil
        }
        firstCapturedAt = clip.firstCapturedAt
        copyCount = clip.copyCount
        fingerprint = clip.fingerprint
        isRemote = clip.isRemote
        sourceName = clip.source?.name
        sourceBundleIdentifier = clip.source?.bundleIdentifier
    }

    var content: ClipContent {
        if let color { return .color(color) }
        if let files { return .files(files) }
        switch (mediaKind, media) {
        case (Self.imageKind, let media?): return .image(media)
        case (Self.pdfKind, let media?): return .pdf(media)
        default: break
        }
        switch textKind {
        case Self.richTextKind: return .richText(text)
        case Self.linkKind: return .link(text)
        case Self.otherKind: return .other
        default: return .text(text)
        }
    }

    var source: ClipSource? {
        sourceName.map { ClipSource(name: $0, bundleIdentifier: sourceBundleIdentifier) }
    }
}
