/// Sorts a copy by its pasteboard types.
public enum ClipClassifier {
    public enum Kind: Equatable, Sendable {
        case text
        case image
        case pdf
    }

    public static let plainTextType = "public.utf8-plain-text"
    public static let pdfType = "com.adobe.pdf"
    public static let imageTypes: Set<String> = [
        "public.png", "public.tiff", "public.jpeg", "public.heic", "com.compuserve.gif",
    ]

    /// Text comes first: a word processor also offers its selection as a PDF and an image.
    public static func kind(of types: Set<String>) -> Kind {
        if types.contains(plainTextType) { return .text }
        if types.contains(pdfType) { return .pdf }
        if !types.isDisjoint(with: imageTypes) { return .image }
        return .text
    }
}
