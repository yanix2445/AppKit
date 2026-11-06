import AppKit
import AppKitCore

/// Starts what a menu bar app needs before any scene appears.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var dependencies: AppDependencies?
    private var historyStrip: HistoryStripController?
    private var statusItem: StatusItemController?
    private let copiedMessage = CopiedMessageController()
    private let settings = SettingsWindowController()
    private let recovery = HistoryRecoveryAlertPresenter()

    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        guard !UITestEnvironment.isHostingUnitTests else { return }
        #endif
        guard let dependencies = try? AppDependencies() else {
            NSApp.terminate(nil)
            return
        }
        self.dependencies = dependencies

        let historyStrip = HistoryStripController(history: dependencies.history) { [weak self] clip in
            self?.restore(clip)
        }
        self.historyStrip = historyStrip
        statusItem = StatusItemController(
            onPrimaryClick: { historyStrip.toggle() },
            onOpenSettings: { [weak self] in self?.settings.show() }
        )
        dependencies.start { [weak self] state in
            self?.handle(state)
        }
    }

    private func handle(_ state: HistoryLifecycleState) {
        statusItem?.setHistoryState(state)
        guard state == .keyMissing else { return }
        // Past the current run of the state change, as the alert runs modally.
        Task {
            await resolveMissingKey()
        }
    }

    private func resolveMissingKey() async {
        guard let lifecycle = dependencies?.lifecycle else { return }
        while lifecycle.state == .keyMissing {
            switch recovery.askForChoice() {
            case .retry:
                await lifecycle.open()
            case .startOver:
                await lifecycle.startOver()
            }
        }
    }

    private func restore(_ clip: Clip) {
        historyStrip?.close()
        Task {
            await dependencies?.restore(clip)
            copiedMessage.show()
        }
    }
}
