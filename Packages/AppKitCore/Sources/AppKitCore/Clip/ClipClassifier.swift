import Foundation

/// Sorts a copy by its pasteboard types and, for a text, by what it says.
public enum ClipClassifier {
    public enum Kind: Equatable, Sendable {
        case text
        case color
        case image
        case pdf
    }

    public static let plainTextType = "public.utf8-plain-text"
    public static let pdfType = "com.adobe.pdf"
    public static let colorType = "com.apple.cocoa.pasteboard.color"
    public static let imageTypes: Set<String> = [
        "public.png", "public.tiff", "public.jpeg", "public.heic", "com.compuserve.gif",
    ]
    public static let richTextTypes: Set<String> = [
        "public.rtf", "com.apple.flat-rtfd", "public.html", "com.apple.webarchive",
    ]
    /// Variants of the same plain text, and a marker that says nothing of the content.
    private static let plainTextVariants: Set<String> = [
        plainTextType, "public.utf16-plain-text", "public.utf16-external-plain-text",
        "NSStringPboardType", "org.nspasteboard.source",
    ]
    private static let linkSchemes: Set<String> = ["http", "https"]

    /// Text comes first: a word processor also offers its selection as a PDF and an image.
    public static func kind(of types: Set<String>) -> Kind {
        if types.contains(plainTextType) { return .text }
        if types.contains(colorType) { return .color }
        if types.contains(pdfType) { return .pdf }
        if !types.isDisjoint(with: imageTypes) { return .image }
        return .text
    }

    /// What a text is, from the narrowest meaning to the broadest.
    public static func content(ofText text: String, types: Set<String>) -> ClipContent {
        if let color = ClipColorParser.color(in: text) { return .color(color) }
        if isLink(text) { return .link(text) }
        if !types.isDisjoint(with: richTextTypes) { return .richText(text) }
        return .text(text)
    }

    /// Whether the copy has more than plain text, and so formats to keep.
    public static func hasOtherFormats(than types: Set<String>) -> Bool {
        !types.subtracting(plainTextVariants).isEmpty
    }

    /// A copy that is nothing but one web address, whatever the spaces around it.
    public static func isLink(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains(where: \.isWhitespace) else { return false }
        let address = trimmed.lowercased().hasPrefix("www.") ? "https://" + trimmed : trimmed
        guard let components = URLComponents(string: address),
              let scheme = components.scheme?.lowercased(),
              linkSchemes.contains(scheme),
              let host = components.host
        else { return false }
        return host.contains(".") || host == "localhost"
    }
}
