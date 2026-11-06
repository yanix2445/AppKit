/// How a copy goes back on the pasteboard. The copy kept in the history never changes.
public enum ClipPasteStyle: Equatable, Sendable {
    /// With all its formats.
    case original
    /// Text alone, without font, color or link.
    case plainText
}
