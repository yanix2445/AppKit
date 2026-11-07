/// What macOS lets AppKit do with the pasteboard.
public enum ClipboardAccess: Equatable, Sendable {
    case allowed
    /// macOS asks the user at the first reading.
    case asks
    case denied
}
