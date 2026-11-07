import Foundation

extension ClipContent {
    /// The longest text kept for searching in one copy, which bounds the size of the search index.
    public static let searchTextLimit = 64 * 1024

    /// The text to search in: without case or accents, cut to the limit.
    public var searchText: String {
        let text: String
        if case .files(let files) = self {
            text = files.map(\.name).joined(separator: " ")
        } else if let plainText {
            text = plainText
        } else {
            return ""
        }
        return String(
            text.prefix(Self.searchTextLimit)
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
        )
    }

    /// Readable on disk, as the category of a copy reveals nothing of its content.
    public var kindIdentifier: String {
        switch self {
        case .text: "text"
        case .richText: "richText"
        case .link: "link"
        case .color: "color"
        case .image: "image"
        case .pdf: "pdf"
        case .files: "files"
        case .other: "other"
        }
    }
}
