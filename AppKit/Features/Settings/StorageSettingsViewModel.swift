import AppKitCore
import Foundation
import Observation

/// The storage settings: a change that would delete copies waits for a confirmation that says
/// exactly what goes, and cancelling leaves everything as it was.
@Observable
final class StorageSettingsViewModel {
    struct PendingChange: Identifiable {
        let id = UUID()
        let policy: ClipStoragePolicy?
        let impact: ClipStorageImpact
    }

    private let lifecycle: HistoryLifecycle
    private let defaults: UserDefaults

    private(set) var policy: ClipStoragePolicy
    private(set) var usage = ClipStorageUsage()
    var pendingChange: PendingChange?

    init(lifecycle: HistoryLifecycle, defaults: UserDefaults) {
        self.lifecycle = lifecycle
        self.defaults = defaults
        policy = .current(in: defaults)
    }

    func refresh() async {
        usage = await lifecycle.storageUsage()
    }

    func request(_ proposed: ClipStoragePolicy) async {
        let impact = await lifecycle.impact(of: proposed)
        if impact.isEmpty {
            await apply(proposed)
        } else {
            pendingChange = PendingChange(policy: proposed, impact: impact)
        }
    }

    func requestErase() async {
        pendingChange = PendingChange(policy: nil, impact: await lifecycle.eraseImpact())
    }

    /// Takes the change as given, as the alert clears the pending one when it closes, before this runs.
    func confirm(_ change: PendingChange) async {
        pendingChange = nil
        if let proposed = change.policy {
            await apply(proposed)
        } else {
            await lifecycle.erase()
            await refresh()
        }
    }

    func cancelPendingChange() {
        pendingChange = nil
    }

    private func apply(_ proposed: ClipStoragePolicy) async {
        proposed.store(in: defaults)
        policy = proposed
        await lifecycle.prune()
        await refresh()
    }
}
