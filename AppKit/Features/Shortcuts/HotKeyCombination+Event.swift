import AppKit
import AppKitCore
import SwiftUI

extension HotKeyCombination {
    /// The shortcut a key press makes, or `nil` for a key that has no name to show.
    init?(event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var modifiers: HotKeyModifiers = []
        if flags.contains(.command) { modifiers.insert(.command) }
        if flags.contains(.shift) { modifiers.insert(.shift) }
        if flags.contains(.option) { modifiers.insert(.option) }
        if flags.contains(.control) { modifiers.insert(.control) }
        let keyCode = UInt32(event.keyCode) == 76 ? 36 : UInt32(event.keyCode)
        guard let character = HotKeyCombination.specialKeyNames[keyCode]
            ?? event.charactersIgnoringModifiers?.uppercased(), !character.isEmpty
        else { return nil }
        self.init(keyCode: keyCode, character: character, modifiers: modifiers)
    }

    /// To show it in a SwiftUI menu.
    var keyboardShortcut: KeyboardShortcut? {
        let key: KeyEquivalent? = switch keyCode {
        case 36: .return
        case 51: .delete
        case 117: .deleteForward
        case 48: .tab
        case 49: .space
        case 123: .leftArrow
        case 124: .rightArrow
        case 125: .downArrow
        case 126: .upArrow
        default: character.lowercased().first.map { KeyEquivalent($0) }
        }
        guard let key else { return nil }
        var eventModifiers: EventModifiers = []
        if modifiers.contains(.command) { eventModifiers.insert(.command) }
        if modifiers.contains(.shift) { eventModifiers.insert(.shift) }
        if modifiers.contains(.option) { eventModifiers.insert(.option) }
        if modifiers.contains(.control) { eventModifiers.insert(.control) }
        return KeyboardShortcut(key, modifiers: eventModifiers)
    }
}
