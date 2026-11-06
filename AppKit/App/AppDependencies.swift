import AppKitCore
import AppKitSystem
import Foundation

/// Creates the real services once, and feeds the history from the pasteboard.
@MainActor
final class AppDependencies {
    let history = ClipHistory()
    private let monitor = ClipboardMonitor(
        pasteboard: SystemPasteboardService(),
        frontmostApp: SystemFrontmostAppService()
    )
    private var captureTask: Task<Void, Never>?

    /// Puts a copy back on the pasteboard and moves it to the top of the history.
    func restore(_ clip: Clip) async {
        await monitor.restore(clip)
        history.promote(clip.id, at: .now)
    }

    func startCapture() {
        captureTask = Task { [history, monitor] in
            for await clip in await monitor.clips() {
                history.insert(clip)
            }
        }
    }
}
