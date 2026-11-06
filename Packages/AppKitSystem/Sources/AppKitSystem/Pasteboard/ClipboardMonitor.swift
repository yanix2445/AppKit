import AppKitCore
import Foundation

/// Watches the pasteboard counter away from the main thread and turns each new text into a clip.
public actor ClipboardMonitor {
    private let pasteboard: any PasteboardService
    private let frontmostApp: any FrontmostAppService
    private let policy: ClipboardPollingPolicy
    private var lastChangeCount: Int

    public init(
        pasteboard: any PasteboardService,
        frontmostApp: any FrontmostAppService,
        policy: ClipboardPollingPolicy = .standard
    ) {
        self.pasteboard = pasteboard
        self.frontmostApp = frontmostApp
        self.policy = policy
        // What was copied before launch is not part of this session.
        self.lastChangeCount = pasteboard.changeCount
    }

    /// Reads the counter once, and returns a clip only if it moved and the pasteboard holds text.
    public func poll() -> Clip? {
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return nil }
        lastChangeCount = changeCount

        guard let text = pasteboard.readText(), !text.isEmpty else { return nil }
        return Clip(
            content: .text(text),
            source: frontmostApp.frontmostApp(),
            capturedAt: .now
        )
    }

    /// New clips, for as long as the stream is being read.
    public func clips() -> AsyncStream<Clip> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: policy.interval, tolerance: policy.tolerance)
                    if let clip = poll() {
                        continuation.yield(clip)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
