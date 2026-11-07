import AppKitCore
import Foundation
import UniformTypeIdentifiers

/// Watches the pasteboard counter away from the main thread and turns each new copy into a capture.
public actor ClipboardMonitor {
    private let pasteboard: any PasteboardService
    private let frontmostApp: any FrontmostAppService
    private let policy: ClipboardPollingPolicy
    private let capturePolicy: @Sendable () -> ClipCapturePolicy
    private var lastChangeCount: Int
    private var isPaused = false
    private var isCapturingRemoteCopy = false

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

        isCapturingRemoteCopy = types.contains(ClipClassifier.remoteClipboardType)
        let capture: ClipCapture?
        switch ClipClassifier.kind(of: types) {
        case .text:
            capture = captureText(types: types)
        case .color:
            capture = captureColor()
        case .image:
            capture = captureMedia { .image($0) }
        case .pdf:
            capture = captureMedia { .pdf($0) }
        case .files:
            capture = captureFiles()
        case .other:
            capture = captureOther()
        }

        // A newer copy may have replaced the one whose types were checked: the next poll judges it.
        guard pasteboard.changeCount == changeCount else { return nil }
        return capture
    }

    private func captureText(types: Set<String>) -> ClipCapture? {
        guard let text = pasteboard.readText(), !text.isEmpty else { return nil }
        return ClipCapture(
            clip: makeClip(content: ClipClassifier.content(ofText: text, types: types)),
            formats: ClipClassifier.hasOtherFormats(than: types) ? pasteboard.readFormats() : []
        )
    }

    private func captureColor() -> ClipCapture? {
        guard let color = pasteboard.readColor() else { return nil }
        return ClipCapture(clip: makeClip(content: .color(color)), formats: pasteboard.readFormats())
    }

    private func captureMedia(_ makeContent: (ClipMedia) -> ClipContent) -> ClipCapture? {
        let formats = pasteboard.readFormats()
        guard !formats.isEmpty else { return nil }
        let byteCount = formats.reduce(0) { $0 + $1.data.count }
        let media = ClipMedia(byteCount: byteCount, isProcessing: true)
        return ClipCapture(clip: makeClip(content: makeContent(media)), formats: formats)
    }

    private func captureFiles() -> ClipCapture? {
        let formats = pasteboard.readFormats()
        let files = ClipFile.files(in: formats)
        guard !files.isEmpty else { return nil }
        if isCapturingRemoteCopy, let capture = captureRemoteFile(files[0]) {
            return capture
        }
        return ClipCapture(clip: makeClip(content: .files(files)), formats: formats)
    }

    /// A photo from another device lands in a temporary folder that belongs to the system and
    /// goes away: its content is kept, not a reference to it.
    private func captureRemoteFile(_ file: ClipFile) -> ClipCapture? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: file.path)) else { return nil }
        let type = UTType(filenameExtension: file.fileExtension)?.identifier ?? "public.data"
        let formats = [ClipRepresentation(type: type, data: data)]
        let media = ClipMedia(byteCount: data.count, isProcessing: true)
        let content: ClipContent
        switch ClipClassifier.kind(of: [type]) {
        case .image: content = .image(media)
        case .pdf: content = .pdf(media)
        default: content = .other
        }
        return ClipCapture(clip: makeClip(content: content), formats: formats)
    }

    private func captureOther() -> ClipCapture? {
        let formats = pasteboard.readFormats()
        guard !formats.isEmpty else { return nil }
        return ClipCapture(clip: makeClip(content: .other), formats: formats)
    }

    private func makeClip(content: ClipContent) -> Clip {
        // The app in front has nothing to do with a copy made on another device.
        Clip(
            content: content,
            source: isCapturingRemoteCopy ? nil : frontmostApp.frontmostApp(),
            capturedAt: .now,
            isRemote: isCapturingRemoteCopy
        )
    }

    public func setPaused(_ isPaused: Bool) {
        self.isPaused = isPaused
    }

    /// Puts a copy back on the pasteboard, without capturing it as a new one.
    /// - Parameter formats: all the formats of the copy, which go back unchanged. Plain text style
    ///   leaves them out, except for an image or a PDF, which have no text to fall back on.
    public func restore(_ clip: Clip, formats: [ClipRepresentation] = [], style: ClipPasteStyle = .original) {
        if let text = clip.content.plainText, style == .plainText || formats.isEmpty {
            lastChangeCount = pasteboard.write(text: text)
        } else {
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
