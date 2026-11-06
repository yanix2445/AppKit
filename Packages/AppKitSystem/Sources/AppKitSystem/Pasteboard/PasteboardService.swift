/// Read access to a pasteboard.
public protocol PasteboardService: Sendable {
    var changeCount: Int { get }
    func readTypes() -> Set<String>
    func readText() -> String?

    /// Replaces the content with this text, and returns the new change count.
    func write(text: String) -> Int
}
