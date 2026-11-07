import AppKitCore
import Foundation
import Observation

/// The pause the user asked for. A pause until resumed outlives a restart of the app or the Mac,
/// and a timed one keeps its end.
@Observable
final class CapturePauseController {
    private static let untilKey = "capturePauseUntil"
    private static let untilResumedKey = "capturePauseUntilResumed"

    private let defaults: UserDefaults
    private let now: () -> Date
    private var expiryTask: Task<Void, Never>?

    private(set) var pause: ClipCapturePause = .none
    private(set) var ignoresNextCopy = false

    /// Told at each change, with whether capture is paused and whether to ignore the next copy.
    var onChange: ((Bool, Bool) -> Void)?

    init(defaults: UserDefaults, now: @escaping () -> Date = { .now }) {
        self.defaults = defaults
        self.now = now
        if defaults.bool(forKey: Self.untilResumedKey) {
            pause = .untilResumed
        } else if let end = defaults.object(forKey: Self.untilKey) as? Date, end > now() {
            pause = .until(end)
            scheduleExpiry(at: end)
        }
    }

    var isPaused: Bool { pause.isActive(at: now()) }

    func pause(for interval: TimeInterval) {
        let end = now().addingTimeInterval(interval)
        set(.until(end))
        scheduleExpiry(at: end)
    }

    func pauseUntilResumed() {
        set(.untilResumed)
    }

    func ignoreNextCopy() {
        ignoresNextCopy = true
        notify()
    }

    /// The copy to ignore has gone by.
    func ignoredCopyWentBy() {
        ignoresNextCopy = false
        notify()
    }

    func resume() {
        ignoresNextCopy = false
        set(.none)
    }

    private func set(_ newPause: ClipCapturePause) {
        expiryTask?.cancel()
        pause = newPause
        switch newPause {
        case .none:
            defaults.removeObject(forKey: Self.untilKey)
            defaults.removeObject(forKey: Self.untilResumedKey)
        case .until(let end):
            defaults.set(end, forKey: Self.untilKey)
            defaults.removeObject(forKey: Self.untilResumedKey)
        case .untilResumed:
            defaults.removeObject(forKey: Self.untilKey)
            defaults.set(true, forKey: Self.untilResumedKey)
        }
        notify()
    }

    private func scheduleExpiry(at end: Date) {
        expiryTask?.cancel()
        expiryTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(max(end.timeIntervalSinceNow, 0)))
            guard !Task.isCancelled else { return }
            self?.set(.none)
        }
    }

    private func notify() {
        onChange?(isPaused, ignoresNextCopy)
    }
}
