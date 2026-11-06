import AppKitCore
import AppKitSystem
import Foundation

/// Registers the shortcut that opens the history. When it is taken, the user chooses another one;
/// the strip stays reachable from the menu bar icon in any case.
final class GlobalHotKeyController {
    static let storageKey = "openHistoryHotKey"

    private let service: any HotKeyService
    private let defaults: UserDefaults
    private let onTrigger: @MainActor () -> Void
    private let askForFallback: (HotKeyCombination, [HotKeyFallback]) -> HotKeyCombination?

    /// The shortcut in effect, if any.
    private(set) var registered: HotKeyCombination?

    init(
        service: any HotKeyService,
        defaults: UserDefaults = .standard,
        onTrigger: @escaping @MainActor () -> Void,
        askForFallback: @escaping (HotKeyCombination, [HotKeyFallback]) -> HotKeyCombination?
    ) {
        self.service = service
        self.defaults = defaults
        self.onTrigger = onTrigger
        self.askForFallback = askForFallback
    }

    func start() {
        let wanted = storedCombination ?? .openHistoryDefault
        guard !tryRegister(wanted) else { return }

        let fallbacks = HotKeyCombination.openHistoryFallbacks
            .filter { $0 != wanted }
            .map { HotKeyFallback(combination: $0, isAvailable: service.isAvailable($0)) }
        guard let chosen = askForFallback(wanted, fallbacks), tryRegister(chosen) else { return }
        store(chosen)
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

    private var storedCombination: HotKeyCombination? {
        defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode(HotKeyCombination.self, from: $0) }
    }

    private func store(_ combination: HotKeyCombination) {
        defaults.set(try? JSONEncoder().encode(combination), forKey: Self.storageKey)
    }
}
