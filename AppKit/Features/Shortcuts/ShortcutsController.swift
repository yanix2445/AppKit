import AppKitCore
import AppKitSystem
import Foundation
import Observation

/// The shortcuts in effect. A change applies at once and stays after a restart; one that cannot be
/// used changes nothing.
@Observable
final class ShortcutsController {
    private let store: ShortcutStore
    private let openHistory: GlobalHotKeyController
    private let togglePause: GlobalHotKeyController

    /// Follows each change, so that everything that shows a shortcut stays right.
    private(set) var current: [HotKeyAction: HotKeyCombination]

    private var isSuspended = false

    init(defaults: UserDefaults, openHistory: GlobalHotKeyController, togglePause: GlobalHotKeyController) {
        store = ShortcutStore(defaults: defaults)
        self.openHistory = openHistory
        self.togglePause = togglePause
        current = store.current
    }

    func start() {
        openHistory.start()
        togglePause.start()
        refresh()
    }

    func combination(for action: HotKeyAction) -> HotKeyCombination? {
        // A global shortcut that macOS refused is not in effect, whatever was chosen.
        guard !isSuspended else { return current[action] }
        return switch action {
        case .openHistory: openHistory.registered
        case .togglePause: togglePause.registered
        default: current[action]
        }
    }

    /// - Returns: what prevents it, in which case nothing has changed.
    @discardableResult
    func set(_ combination: HotKeyCombination, for action: HotKeyAction) -> HotKeyProblem? {
        if let problem = HotKeyPolicy.problem(with: combination, for: action, current: store.current) {
            return problem
        }
        if let controller = globalController(for: action) {
            guard controller.change(to: combination) else { return .takenElsewhere }
        } else {
            store.set(combination, for: action)
        }
        refresh()
        return nil
    }

    func erase(_ action: HotKeyAction) {
        if let controller = globalController(for: action) {
            controller.erase()
        } else {
            store.set(nil, for: action)
        }
        refresh()
    }

    /// - Returns: what prevents it, such as another action now holding the default.
    @discardableResult
    func reset(_ action: HotKeyAction) -> HotKeyProblem? {
        let problem = set(action.defaultCombination, for: action)
        if problem == nil {
            store.reset(action)
            refresh()
        }
        return problem
    }

    /// Back to all the defaults. Global shortcuts that another app holds meanwhile stay erased.
    func resetAll() {
        for action in HotKeyAction.allCases {
            store.reset(action)
        }
        openHistory.reload()
        togglePause.reload()
        refresh()
    }

    /// While a shortcut is being typed, a global one must not trigger its action.
    func suspendGlobalShortcuts() {
        isSuspended = true
        openHistory.suspend()
        togglePause.suspend()
    }

    func resumeGlobalShortcuts() {
        isSuspended = false
        openHistory.reload()
        togglePause.reload()
        refresh()
    }

    private func globalController(for action: HotKeyAction) -> GlobalHotKeyController? {
        switch action {
        case .openHistory: openHistory
        case .togglePause: togglePause
        default: nil
        }
    }

    private func refresh() {
        current = store.current
    }
}
