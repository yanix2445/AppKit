/// Why a shortcut cannot be used.
public enum HotKeyProblem: Equatable, Sendable {
    /// A global shortcut needs ⌘, ⌃ or ⌥.
    case needsGlobalModifier
    /// In the strip, a plain key is text for the search.
    case needsModifierOrSpecialKey
    case reservedByMacOS
    /// The strip already uses it for itself, such as ⌘Z or the arrows.
    case reservedByStrip
    case takenByAction(HotKeyAction)
    case takenElsewhere
}
