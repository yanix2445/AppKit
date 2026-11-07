import Foundation
import Observation

/// Remembers which explanations were seen. One shows at a time.
@Observable
final class HistoryStripTips {
    private let defaults: UserDefaults

    private(set) var active: HistoryStripTip?

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    static func key(for tip: HistoryStripTip) -> String {
        "tipSeen.\(tip.rawValue)"
    }

    /// Counts as seen from the moment it shows: closing the strip does not bring it back.
    func show(_ tip: HistoryStripTip) {
        guard !defaults.bool(forKey: Self.key(for: tip)) else { return }
        defaults.set(true, forKey: Self.key(for: tip))
        active = tip
    }

    /// In « Copier seulement », nothing is pasted where the user was writing.
    var pastesDirectly: Bool {
        defaults.string(forKey: PasteMode.storageKey) != PasteMode.copyOnly.rawValue
    }

    func dismiss() {
        active = nil
    }
}
