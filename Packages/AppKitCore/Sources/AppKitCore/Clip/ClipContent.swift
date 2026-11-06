/// What a copy holds.
public enum ClipContent: Equatable, Sendable {
    case text(String)
    case image(ClipMedia)
    case pdf(ClipMedia)

    /// The number of lines shown on the card, counting empty ones.
    public var lineCount: Int {
        switch self {
        case .text(let text):
            text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).count
        case .image, .pdf:
            0
        }
    }

    public var media: ClipMedia? {
        switch self {
        case .text: nil
        case .image(let media), .pdf(let media): media
        }
    }

    public func replacingMedia(with media: ClipMedia) -> ClipContent {
        switch self {
        case .text: self
        case .image: .image(media)
        case .pdf: .pdf(media)
        }
    }
}
