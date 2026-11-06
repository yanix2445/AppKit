/// What a copy holds.
public enum ClipContent: Equatable, Sendable {
    case text(String)
    case richText(String)
    case link(String)
    case color(ClipColor)
    case image(ClipMedia)
    case pdf(ClipMedia)

    /// The text to paste when formats are left out; an image or a PDF has none.
    public var plainText: String? {
        switch self {
        case .text(let text), .richText(let text), .link(let text): text
        case .color(let color): color.text
        case .image, .pdf: nil
        }
    }

    /// The number of lines shown on the card, counting empty ones.
    public var lineCount: Int {
        plainText?.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).count ?? 0
    }

    public var media: ClipMedia? {
        switch self {
        case .image(let media), .pdf(let media): media
        case .text, .richText, .link, .color: nil
        }
    }

    public func replacingMedia(with media: ClipMedia) -> ClipContent {
        switch self {
        case .image: .image(media)
        case .pdf: .pdf(media)
        case .text, .richText, .link, .color: self
        }
    }
}
