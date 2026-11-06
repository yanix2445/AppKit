/// Read access to a pasteboard.
public protocol PasteboardService: Sendable {
    var changeCount: Int { get }
    func readText() -> String?
}
