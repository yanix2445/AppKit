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

    /// The keys that write no text, with the names AppKit shows for them.
    public static let specialKeyNames: [UInt32: String] = [
        36: "↩", 48: "⇥", 49: "␣", 51: "⌫", 53: "⎋", 117: "⌦",
        123: "←", 124: "→", 125: "↓", 126: "↑",
        122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
        98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
    ]

    /// A space writes text, so it does not count here.
    public var isSpecialKey: Bool {
        keyCode != 49 && Self.specialKeyNames[keyCode] != nil
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
