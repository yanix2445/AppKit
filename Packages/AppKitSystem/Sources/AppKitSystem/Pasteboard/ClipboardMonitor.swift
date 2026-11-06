import AppKitCore
import Foundation

/// Watches the pasteboard counter away from the main thread and turns each new copy into a capture.
public actor ClipboardMonitor {
    private let pasteboard: any PasteboardService
    private let frontmostApp: any FrontmostAppService
    private let policy: ClipboardPollingPolicy
    private let capturePolicy: @Sendable () -> ClipCapturePolicy
    private var lastChangeCount: Int
    private var isPaused = false

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

    /// Reads the counter once, and returns a capture only if it moved and the copy may be kept.
    /// The types are checked first, so a refused copy is never even read.
    public func poll() -> ClipCapture? {
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return nil }
        lastChangeCount = changeCount

        // During a pause, a copy is passed over without being read.
        guard !isPaused else { return nil }

        let types = pasteboard.readTypes()
        guard capturePolicy().allows(types: types) else { return nil }

        let capture: ClipCapture?
        switch ClipClassifier.kind(of: types) {
        case .text:
            capture = captureText()
        case .image:
            capture = captureMedia { .image($0) }
        case .pdf:
            capture = captureMedia { .pdf($0) }
        }

        // A newer copy may have replaced the one whose types were checked: the next poll judges it.
        guard pasteboard.changeCount == changeCount else { return nil }
        return capture
    }

    private func captureText() -> ClipCapture? {
        guard let text = pasteboard.readText(), !text.isEmpty else { return nil }
        return ClipCapture(clip: makeClip(content: .text(text)))
    }

    private func captureMedia(_ makeContent: (ClipMedia) -> ClipContent) -> ClipCapture? {
        let formats = pasteboard.readFormats()
        guard !formats.isEmpty else { return nil }
        let byteCount = formats.reduce(0) { $0 + $1.data.count }
        let media = ClipMedia(byteCount: byteCount, isProcessing: true)
        return ClipCapture(clip: makeClip(content: makeContent(media)), formats: formats)
    }

    private func makeClip(content: ClipContent) -> Clip {
        Clip(content: content, source: frontmostApp.frontmostApp(), capturedAt: .now)
    }

    public func setPaused(_ isPaused: Bool) {
        self.isPaused = isPaused
    }

    /// Puts a copy back on the pasteboard, without capturing it as a new one.
    /// - Parameter formats: all the formats of an image or a PDF, which go back unchanged.
    public func restore(_ clip: Clip, formats: [ClipRepresentation] = [], style: ClipPasteStyle = .original) {
        // For now a text only holds text, so both styles write the same thing.
        switch clip.content {
        case .text(let text):
            lastChangeCount = pasteboard.write(text: text)
        case .image, .pdf:
            lastChangeCount = pasteboard.write(formats: formats)
        }
    }

    /// New captures, for as long as the stream is being read.
    public func captures() -> AsyncStream<ClipCapture> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: policy.interval, tolerance: policy.tolerance)
                    if let capture = poll() {
                        continuation.yield(capture)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
