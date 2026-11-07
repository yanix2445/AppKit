/// The categories a copy can fall into, as the filters and the exclusions name them.
public enum ClipCategory: String, CaseIterable, Sendable {
    case text, richText, link, image, files, color, pdf, other

    public init(_ content: ClipContent) {
        switch content {
        case .text: self = .text
        case .richText: self = .richText
        case .link: self = .link
        case .color: self = .color
        case .image: self = .image
        case .pdf: self = .pdf
        case .files: self = .files
        case .other: self = .other
        }
    }
}
