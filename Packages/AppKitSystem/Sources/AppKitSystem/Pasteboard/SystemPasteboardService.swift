import AppKit
import AppKitCore

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

    public func readColor() -> ClipColor? {
        let pasteboard = NSPasteboard(name: name)
        guard let colors = pasteboard.readObjects(forClasses: [NSColor.self]) as? [NSColor],
              let color = colors.first?.usingColorSpace(.sRGB)
        else { return nil }
        return ClipColor(
            red: Double(color.redComponent),
            green: Double(color.greenComponent),
            blue: Double(color.blueComponent),
            alpha: Double(color.alphaComponent)
        )
    }

    public func readFormats() -> [ClipRepresentation] {
        let items = NSPasteboard(name: name).pasteboardItems ?? []
        return items.enumerated().flatMap { index, item in
            item.types.compactMap { type in
                item.data(forType: type).map {
                    ClipRepresentation(type: type.rawValue, data: $0, itemIndex: index)
                }
            }
        }
    }

    public func write(formats: [ClipRepresentation]) -> Int {
        let pasteboard = NSPasteboard(name: name)
        pasteboard.clearContents()
        let elements = Dictionary(grouping: formats, by: \.itemIndex)
        let items = elements.keys.sorted().map { index in
            let item = NSPasteboardItem()
            for format in elements[index] ?? [] {
                item.setData(format.data, forType: NSPasteboard.PasteboardType(format.type))
            }
            return item
        }
        pasteboard.writeObjects(items)
        return pasteboard.changeCount
    }

    public func write(text: String) -> Int {
        let pasteboard = NSPasteboard(name: name)
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        return pasteboard.changeCount
    }
}
