/// What can have a shortcut, each with the one it starts with.
public enum HotKeyAction: String, CaseIterable, Sendable {
    case openHistory, togglePause, paste, pastePlainText, delete, togglePin, movePinnedLeft, movePinnedRight

    /// Works from any app; the others work only in the strip.
    public var isGlobal: Bool {
        self == .openHistory || self == .togglePause
    }

    public var defaultCombination: HotKeyCombination {
        switch self {
        case .openHistory: .openHistoryDefault
        case .togglePause: HotKeyCombination(keyCode: 35, character: "P", modifiers: [.control, .option, .command])
        case .paste: HotKeyCombination(keyCode: 36, character: "↩", modifiers: [])
        case .pastePlainText: HotKeyCombination(keyCode: 36, character: "↩", modifiers: [.shift])
        case .delete: HotKeyCombination(keyCode: 51, character: "⌫", modifiers: [])
        case .togglePin: HotKeyCombination(keyCode: 35, character: "P", modifiers: [.command])
        case .movePinnedLeft: HotKeyCombination(keyCode: 123, character: "←", modifiers: [.option, .command])
        case .movePinnedRight: HotKeyCombination(keyCode: 124, character: "→", modifiers: [.option, .command])
        }
    }
}
