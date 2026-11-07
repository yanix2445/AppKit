import AppKitSystem
import Foundation

/// Pastes a chosen copy where the user was writing, or falls back on the pasteboard.
final class DirectPasteCoordinator {
    static let explanationSeenKey = "directPasteExplanationSeen"

    private let service: any DirectPasteService
    private let defaults: UserDefaults
    private let focusReturnDelay: Duration
    private let askToOpenSettings: () -> Bool

    /// - Parameter askToOpenSettings: explains the permission; `true` opens System Settings.
    init(
        service: any DirectPasteService,
        defaults: UserDefaults = .standard,
        focusReturnDelay: Duration = Motion.focusReturnDelay,
        askToOpenSettings: @escaping () -> Bool
    ) {
        self.service = service
        self.defaults = defaults
        self.focusReturnDelay = focusReturnDelay
        self.askToOpenSettings = askToOpenSettings
    }

    func deliver() async -> DirectPasteOutcome {
        guard defaults.string(forKey: PasteMode.storageKey) != PasteMode.copyOnly.rawValue else {
            return .copied(offersEnabling: false)
        }
        guard service.isTrusted else {
            explainOnce()
            return .copied(offersEnabling: true)
        }
        // The strip just left the screen: leave the keyboard time to go back to the app.
        try? await Task.sleep(for: focusReturnDelay, tolerance: Motion.focusReturnTolerance)
        guard service.focusedTarget() != .notEditable else {
            return .copied(offersEnabling: false)
        }
        service.postPaste()
        return .pasted
    }

    func enable() {
        service.openAccessibilitySettings()
    }

    private func explainOnce() {
        guard !defaults.bool(forKey: Self.explanationSeenKey) else { return }
        defaults.set(true, forKey: Self.explanationSeenKey)
        if askToOpenSettings() {
            service.openAccessibilitySettings()
        }
    }
}
