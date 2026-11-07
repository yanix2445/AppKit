/// The rules a new shortcut must follow, before asking macOS whether it is free.
public enum HotKeyPolicy {
    private static let keyCodeEscape: UInt32 = 53
    private static let keyCodeTab: UInt32 = 48
    private static let keyCodeSpace: UInt32 = 49
    /// ⌘ with these belongs to every Mac app: quit, close, hide, minimize.
    private static let macOSCommandLetters: Set<String> = ["Q", "W", "H", "M"]
    /// ⌘ with these edits the text of the search, or undoes a removal.
    private static let stripCommandLetters: Set<String> = ["A", "C", "V", "X", "Z"]
    private static let digitKeyCodes: Set<UInt32> = [18, 19, 20, 21, 23, 22, 26, 28, 25]
    private static let arrowKeyCodes: Set<UInt32> = [123, 124, 125, 126]

    /// - Parameter current: the shortcut of each action now.
    public static func problem(
        with combination: HotKeyCombination,
        for action: HotKeyAction,
        current: [HotKeyAction: HotKeyCombination]
    ) -> HotKeyProblem? {
        if isReservedByMacOS(combination) { return .reservedByMacOS }
        if action.isGlobal {
            guard !combination.modifiers.isDisjoint(with: [.command, .control, .option]) else {
                return .needsGlobalModifier
            }
        } else {
            if isReservedByStrip(combination) { return .reservedByStrip }
            let onlyShift = combination.modifiers.isEmpty || combination.modifiers == [.shift]
            guard !onlyShift || combination.isSpecialKey else { return .needsModifierOrSpecialKey }
        }
        for other in HotKeyAction.allCases where other != action && current[other] == combination {
            return .takenByAction(other)
        }
        return nil
    }

    private static func isReservedByMacOS(_ combination: HotKeyCombination) -> Bool {
        if combination.modifiers == [.command] {
            if macOSCommandLetters.contains(combination.character.uppercased()) { return true }
            if combination.keyCode == keyCodeTab || combination.keyCode == keyCodeSpace { return true }
        }
        return combination.keyCode == keyCodeEscape && combination.modifiers == [.option, .command]
    }

    private static func isReservedByStrip(_ combination: HotKeyCombination) -> Bool {
        if combination.keyCode == keyCodeEscape { return true }
        if combination.modifiers.isEmpty, arrowKeyCodes.contains(combination.keyCode) { return true }
        guard combination.modifiers == [.command] else { return false }
        return stripCommandLetters.contains(combination.character.uppercased())
            || digitKeyCodes.contains(combination.keyCode)
    }
}
