import AppKitCore
import Foundation

/// Keeps the shortcut chosen for each action. Without a choice, an action has its default one.
struct ShortcutStore {
    let defaults: UserDefaults

    private static func key(for action: HotKeyAction) -> String {
        action == .openHistory ? GlobalHotKeyController.storageKey : "hotKey.\(action.rawValue)"
    }

    /// `nil` when the user has erased it.
    func combination(for action: HotKeyAction) -> HotKeyCombination? {
        guard let data = defaults.data(forKey: Self.key(for: action)) else { return action.defaultCombination }
        return try? JSONDecoder().decode(HotKeyCombination.self, from: data)
    }

    func set(_ combination: HotKeyCombination?, for action: HotKeyAction) {
        // Empty data stands for a shortcut erased, as opposed to no choice at all.
        let data = combination.flatMap { try? JSONEncoder().encode($0) } ?? Data()
        defaults.set(data, forKey: Self.key(for: action))
    }

    func reset(_ action: HotKeyAction) {
        defaults.removeObject(forKey: Self.key(for: action))
    }

    var current: [HotKeyAction: HotKeyCombination] {
        var result: [HotKeyAction: HotKeyCombination] = [:]
        for action in HotKeyAction.allCases {
            result[action] = combination(for: action)
        }
        return result
    }
}
