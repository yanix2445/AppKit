import Foundation

/// A keyboard shortcut. The key code is the physical key, whatever the keyboard layout.
public struct HotKeyCombination: Hashable, Codable, Sendable {
    public let keyCode: UInt32
    public let character: String
    public let modifiers: HotKeyModifiers

    public init(keyCode: UInt32, character: String, modifiers: HotKeyModifiers) {
        self.keyCode = keyCode
        self.character = character
        self.modifiers = modifiers
    }

    /// The symbols in the order macOS shows them, such as ["⇧", "⌘", "V"].
    public var symbols: [String] {
        var symbols: [String] = []
        if modifiers.contains(.control) { symbols.append("⌃") }
        if modifiers.contains(.option) { symbols.append("⌥") }
        if modifiers.contains(.shift) { symbols.append("⇧") }
        if modifiers.contains(.command) { symbols.append("⌘") }
        symbols.append(character)
        return symbols
    }

    public var displayName: String {
        symbols.joined()
    }

    private static let keyCodeV: UInt32 = 9
    private static let keyCodeC: UInt32 = 8

    public static let openHistoryDefault = HotKeyCombination(
        keyCode: keyCodeV, character: "V", modifiers: [.shift, .command]
    )

    /// Offered when the default is taken, in this order.
    public static let openHistoryFallbacks = [
        HotKeyCombination(keyCode: keyCodeV, character: "V", modifiers: [.option, .command]),
        HotKeyCombination(keyCode: keyCodeC, character: "C", modifiers: [.shift, .command]),
        HotKeyCombination(keyCode: keyCodeV, character: "V", modifiers: [.control, .command]),
    ]
}
