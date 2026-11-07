import AppKitCore
import Foundation

/// The keys the strip answers to, whatever is in focus. Key codes do not depend on the keyboard
/// layout, which matters for the digits of an AZERTY keyboard.
enum HistoryStripKey: Equatable {
    case escape
    case choose(plainText: Bool)
    case move(left: Bool)
    case vertical
    case delete(command: Bool)
    case togglePin
    case undo
    case movePinned(left: Bool)
    /// `0` is all the copies, then each category in order.
    case filter(Int)

    struct Modifiers: Equatable {
        var command = false
        var shift = false
        var option = false
        var control = false

        var isEmpty: Bool { !command && !shift && !option && !control }
    }

    private static let digitKeyCodes: [UInt16] = [18, 19, 20, 21, 23, 22, 26, 28, 25]

    /// - Parameter bindings: the shortcuts the user chose; the other keys of the strip are fixed.
    init?(
        keyCode: UInt16,
        character: String?,
        modifiers: Modifiers,
        bindings: [HotKeyAction: HotKeyCombination] = Self.defaultBindings
    ) {
        if let action = Self.action(keyCode: keyCode, character: character, modifiers: modifiers, bindings: bindings) {
            switch action {
            case .paste: self = .choose(plainText: false)
            case .pastePlainText: self = .choose(plainText: true)
            case .delete: self = .delete(command: !modifiers.isEmpty)
            case .togglePin: self = .togglePin
            case .movePinnedLeft: self = .movePinned(left: true)
            case .movePinnedRight: self = .movePinned(left: false)
            case .openHistory, .togglePause: return nil
            }
            return
        }
        let commandOnly = modifiers == Modifiers(command: true)
        switch keyCode {
        case 53 where modifiers.isEmpty:
            self = .escape
        case 123 where modifiers.isEmpty, 124 where modifiers.isEmpty:
            self = .move(left: keyCode == 123)
        case 125 where modifiers.isEmpty, 126 where modifiers.isEmpty:
            self = .vertical
        case 51 where commandOnly:
            self = .delete(command: true)
        default:
            guard commandOnly else { return nil }
            if let digit = Self.digitKeyCodes.firstIndex(of: keyCode) {
                self = .filter(digit)
            } else if character?.lowercased() == "z" {
                self = .undo
            } else {
                return nil
            }
        }
    }

    static var defaultBindings: [HotKeyAction: HotKeyCombination] {
        Dictionary(uniqueKeysWithValues: HotKeyAction.allCases.map { ($0, $0.defaultCombination) })
    }

    /// A letter is found by what it writes, as the same key writes another letter on another
    /// layout; a special key by its place.
    private static func action(
        keyCode: UInt16,
        character: String?,
        modifiers: Modifiers,
        bindings: [HotKeyAction: HotKeyCombination]
    ) -> HotKeyAction? {
        var wanted: HotKeyModifiers = []
        if modifiers.command { wanted.insert(.command) }
        if modifiers.shift { wanted.insert(.shift) }
        if modifiers.option { wanted.insert(.option) }
        if modifiers.control { wanted.insert(.control) }
        let code = keyCode == 76 ? 36 : UInt32(keyCode)
        return HotKeyAction.allCases.first { action in
            guard !action.isGlobal, let combination = bindings[action], combination.modifiers == wanted else { return false }
            return combination.isSpecialKey
                ? combination.keyCode == code
                : combination.character.uppercased() == character?.uppercased() || combination.keyCode == code
        }
    }
}
