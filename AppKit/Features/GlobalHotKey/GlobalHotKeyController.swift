import AppKitCore
import AppKitSystem
import Foundation

/// Registers a shortcut that works from any app. When the one that opens the history is taken, the
/// user chooses another one; the strip stays reachable from the menu bar icon in any case.
final class GlobalHotKeyController {
    static let storageKey = "openHistoryHotKey"

    private let action: HotKeyAction
    private let service: any HotKeyService
    private let store: ShortcutStore
    private let onTrigger: @MainActor () -> Void
    private let askForFallback: ((HotKeyCombination, [HotKeyFallback]) -> HotKeyCombination?)?

    /// The shortcut in effect, if any.
    private(set) var registered: HotKeyCombination?

    init(
        action: HotKeyAction = .openHistory,
        service: any HotKeyService,
        defaults: UserDefaults = .standard,
        onTrigger: @escaping @MainActor () -> Void,
        askForFallback: ((HotKeyCombination, [HotKeyFallback]) -> HotKeyCombination?)? = nil
    ) {
        self.action = action
        self.service = service
        store = ShortcutStore(defaults: defaults)
        self.onTrigger = onTrigger
        self.askForFallback = askForFallback
    }

    func start() {
        guard let wanted = store.combination(for: action), !tryRegister(wanted), let askForFallback else { return }
        let fallbacks = HotKeyCombination.openHistoryFallbacks
            .filter { $0 != wanted }
            .map { HotKeyFallback(combination: $0, isAvailable: service.isAvailable($0)) }
        guard let chosen = askForFallback(wanted, fallbacks), tryRegister(chosen) else { return }
        store.set(chosen, for: action)
    }

    /// - Returns: whether macOS took it. If not, the previous shortcut stays in effect.
    func change(to combination: HotKeyCombination) -> Bool {
        let previous = store.combination(for: action)
        guard tryRegister(combination) else {
            if let previous { _ = tryRegister(previous) }
            return false
        }
        store.set(combination, for: action)
        return true
    }

    func erase() {
        service.unregister()
        registered = nil
        store.set(nil, for: action)
    }

    func suspend() {
        service.unregister()
        registered = nil
    }

    /// Takes back what is stored, without asking anything if it is no longer free.
    func reload() {
        service.unregister()
        registered = nil
        if let wanted = store.combination(for: action) {
            _ = tryRegister(wanted)
        }
    }

    private func tryRegister(_ combination: HotKeyCombination) -> Bool {
        do {
            try service.register(combination, onTrigger: onTrigger)
            registered = combination
            return true
        } catch {
            registered = nil
            return false
        }
    }
}
