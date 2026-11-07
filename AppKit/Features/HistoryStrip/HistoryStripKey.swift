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

    init?(keyCode: UInt16, character: String?, modifiers: Modifiers) {
        let commandOnly = modifiers == Modifiers(command: true)
        switch keyCode {
        case 53 where modifiers.isEmpty:
            self = .escape
        case 36, 76:
            guard modifiers.isEmpty || modifiers == Modifiers(shift: true) else { return nil }
            self = .choose(plainText: modifiers.shift)
        case 123, 124:
            if modifiers.isEmpty {
                self = .move(left: keyCode == 123)
            } else if modifiers == Modifiers(command: true, option: true) {
                self = .movePinned(left: keyCode == 123)
            } else {
                return nil
            }
        case 125, 126 where modifiers.isEmpty:
            self = .vertical
        case 51 where modifiers.isEmpty || commandOnly:
            self = .delete(command: modifiers.command)
        default:
            guard commandOnly else { return nil }
            if let digit = Self.digitKeyCodes.firstIndex(of: keyCode) {
                self = .filter(digit)
            } else if character?.lowercased() == "p" {
                self = .togglePin
            } else if character?.lowercased() == "z" {
                self = .undo
            } else {
                return nil
            }
        }
    }
}
