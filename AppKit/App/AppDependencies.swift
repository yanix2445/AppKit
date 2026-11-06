import AppKitCore
import AppKitSystem

/// Creates the real services once, and feeds the history from the pasteboard.
@MainActor
final class AppDependencies {
    let history = ClipHistory()
    private let monitor = ClipboardMonitor(
        pasteboard: SystemPasteboardService(),
        frontmostApp: SystemFrontmostAppService()
    )
    private var captureTask: Task<Void, Never>?

    func startCapture() {
        captureTask = Task { [history, monitor] in
            for await clip in await monitor.clips() {
                history.insert(clip)
            }
        }
    }
}
