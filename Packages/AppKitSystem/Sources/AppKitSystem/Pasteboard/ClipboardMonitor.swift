import AppKitCore
import Foundation

/// Watches the pasteboard counter away from the main thread and turns each new text into a clip.
public actor ClipboardMonitor {
    private let pasteboard: any PasteboardService
    private let frontmostApp: any FrontmostAppService
    private let policy: ClipboardPollingPolicy
    private let capturePolicy: @Sendable () -> ClipCapturePolicy
    private var lastChangeCount: Int

    public init(
        pasteboard: any PasteboardService,
        frontmostApp: any FrontmostAppService,
        policy: ClipboardPollingPolicy = .standard,
        capturePolicy: @escaping @Sendable () -> ClipCapturePolicy = { ClipCapturePolicy() }
    ) {
        self.pasteboard = pasteboard
        self.frontmostApp = frontmostApp
        self.policy = policy
        self.capturePolicy = capturePolicy
        // What was copied before launch is not part of this session.
        self.lastChangeCount = pasteboard.changeCount
    }

    /// Reads the counter once, and returns a clip only if it moved and the pasteboard holds text
    /// that may be kept. The types are checked first, so a refused copy is never even read.
    public func poll() -> Clip? {
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return nil }
        lastChangeCount = changeCount

        guard capturePolicy().allows(types: pasteboard.readTypes()),
              let text = pasteboard.readText(),
              !text.isEmpty
        else { return nil }

        // A newer copy may have replaced the one whose types were checked: the next poll judges it.
        guard pasteboard.changeCount == changeCount else { return nil }

        return Clip(
            content: .text(text),
            source: frontmostApp.frontmostApp(),
            capturedAt: .now
        )
    }

    /// Puts a copy back on the pasteboard, without capturing it as a new one.
    public func restore(_ clip: Clip) {
        switch clip.content {
        case .text(let text):
            lastChangeCount = pasteboard.write(text: text)
        }
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
