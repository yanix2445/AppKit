/// What a copy holds.
public enum ClipContent: Equatable, Sendable {
    case text(String)

    /// The number of lines shown on the card, counting empty ones.
    public var lineCount: Int {
        switch self {
        case .text(let text):
            text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).count
        }
    }
}
