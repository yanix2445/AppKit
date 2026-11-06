import AppKit
import AppKitCore

/// Starts what a menu bar app needs before any scene appears.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let dependencies = AppDependencies()
    private var historyStrip: HistoryStripController?
    private var statusItem: StatusItemController?
    private let copiedMessage = CopiedMessageController()
    private let settings = SettingsWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let historyStrip = HistoryStripController(history: dependencies.history) { [weak self] clip in
            self?.restore(clip)
        }
        self.historyStrip = historyStrip
        statusItem = StatusItemController(
            onPrimaryClick: { historyStrip.toggle() },
            onOpenSettings: { [weak self] in self?.settings.show() }
        )
        dependencies.startCapture()
    }

    private func restore(_ clip: Clip) {
        historyStrip?.close()
        Task {
            await dependencies.restore(clip)
            copiedMessage.show()
        }
    }
}
