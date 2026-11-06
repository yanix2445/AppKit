import AppKit

/// Reads a real pasteboard. It keeps the name rather than the object, which is not `Sendable`.
public struct SystemPasteboardService: PasteboardService {
    private let name: NSPasteboard.Name

    public init(name: NSPasteboard.Name = .general) {
        self.name = name
    }

    public var changeCount: Int {
        NSPasteboard(name: name).changeCount
    }

    public func readText() -> String? {
        NSPasteboard(name: name).string(forType: .string)
    }
}
