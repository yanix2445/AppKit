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

    /// Reads the types of every item without fetching any content.
    public func readTypes() -> Set<String> {
        let pasteboard = NSPasteboard(name: name)
        var types = Set((pasteboard.types ?? []).map(\.rawValue))
        for item in pasteboard.pasteboardItems ?? [] {
            types.formUnion(item.types.map(\.rawValue))
        }
        return types
    }

    public func readText() -> String? {
        NSPasteboard(name: name).string(forType: .string)
    }

    public func write(text: String) -> Int {
        let pasteboard = NSPasteboard(name: name)
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        return pasteboard.changeCount
    }
}
