/// A shortcut offered in place of one that is taken.
public struct HotKeyFallback: Equatable, Sendable {
    public let combination: HotKeyCombination
    public let isAvailable: Bool

    public init(combination: HotKeyCombination, isAvailable: Bool) {
        self.combination = combination
        self.isAvailable = isAvailable
    }
}
