import AppKit

/// Starts what a menu bar app needs before any scene appears.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let dependencies = AppDependencies()
    private var historyStrip: HistoryStripController?
    private var statusItem: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let historyStrip = HistoryStripController(history: dependencies.history)
        self.historyStrip = historyStrip
        statusItem = StatusItemController { historyStrip.toggle() }
        dependencies.startCapture()
    }
}
