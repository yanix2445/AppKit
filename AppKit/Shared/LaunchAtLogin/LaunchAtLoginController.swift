import AppKitSystem
import Foundation
import Observation

/// Reflects what macOS says about starting at login, and offers it once at the first launch.
@Observable
final class LaunchAtLoginController {
    static let offerSeenKey = "launchAtLoginOfferSeen"

    private let service: any LaunchAtLoginService
    private let defaults: UserDefaults

    private(set) var status: LaunchAtLoginStatus
    private(set) var hasFailed = false

    init(service: any LaunchAtLoginService, defaults: UserDefaults = .standard) {
        self.service = service
        self.defaults = defaults
        status = service.status
    }

    /// Read again whenever it matters, as the user can change it in System Settings.
    func refresh() {
        status = service.status
    }

    func setEnabled(_ isEnabled: Bool) {
        do {
            if isEnabled {
                try service.enable()
            } else {
                try service.disable()
            }
            hasFailed = false
        } catch {
            hasFailed = true
        }
        refresh()
    }

    func openSystemSettings() {
        service.openSystemSettings()
    }

    /// At the first launch only, whatever the answer.
    func offerOnce(ask: () -> Bool) {
        guard !defaults.bool(forKey: Self.offerSeenKey) else { return }
        defaults.set(true, forKey: Self.offerSeenKey)
        refresh()
        guard status == .disabled, ask() else { return }
        setEnabled(true)
    }
}
