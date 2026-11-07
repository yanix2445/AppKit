import AppKit
import AppKitCore
import AppKitData
import AppKitSystem
import Foundation
import SwiftData

/// Creates the real services once, and feeds the history from the pasteboard.
final class AppDependencies {
    let lifecycle: HistoryLifecycle
    let directPasteService: any DirectPasteService
    let directPasteDefaults: UserDefaults
    let launchAtLogin: LaunchAtLoginController
    let pause: CapturePauseController
    let feedback: CopyFeedbackController
    let clipboardAccess: any ClipboardAccessService
    private var capturesCopies = false
    /// Nothing is read before the user knows why, nor once macOS refuses.
    private var canReadClipboard = false
    private let monitor: ClipboardMonitor
    private var captureTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?

    var history: ClipHistory { lifecycle.history }
    var onFilesCaptured: (([ClipFile]) -> Void)?

    init() throws {
        let location = AppDependencies.makeLocation()
        // Apple documents UserDefaults as thread-safe, though it is not marked Sendable.
        nonisolated(unsafe) let defaults = location.directPasteDefaults
        directPasteService = location.directPasteService
        directPasteDefaults = location.directPasteDefaults
        clipboardAccess = location.clipboardAccess
        launchAtLogin = LaunchAtLoginController(service: location.launchAtLoginService, defaults: location.directPasteDefaults)
        monitor = ClipboardMonitor(
            pasteboard: SystemPasteboardService(name: location.pasteboardName),
            frontmostApp: SystemFrontmostAppService(),
            capturePolicy: { ClipCapturePolicy.current(in: defaults) }
        )
        pause = CapturePauseController(defaults: location.directPasteDefaults)
        feedback = CopyFeedbackController(sounds: location.soundService, defaults: location.directPasteDefaults)
        lifecycle = HistoryLifecycle(
            history: ClipHistory(),
            store: ClipStore(modelContainer: try .history(at: location.storeURL)),
            keyService: location.keyService,
            diskSpace: SystemDiskSpaceService(url: location.storeURL.deletingLastPathComponent()),
            thumbnails: SystemClipThumbnailService(),
            storagePolicy: { ClipStoragePolicy.current(in: defaults) }
        )
    }

    private struct Location {
        let storeURL: URL
        let keyService: any EncryptionKeyService
        let pasteboardName: NSPasteboard.Name
        let directPasteService: any DirectPasteService
        let directPasteDefaults: UserDefaults
        let launchAtLoginService: any LaunchAtLoginService
        let soundService: any SoundService
        let clipboardAccess: any ClipboardAccessService
    }

    private static func makeLocation() -> Location {
        #if DEBUG
        if let environment = UITestEnvironment.current {
            return Location(
                storeURL: environment.storeURL,
                keyService: environment.keyService,
                pasteboardName: NSPasteboard.Name(environment.pasteboardName),
                directPasteService: environment.directPasteService,
                directPasteDefaults: environment.directPasteDefaults,
                launchAtLoginService: environment.launchAtLoginService,
                soundService: environment.soundService,
                clipboardAccess: environment.clipboardAccess
            )
        }
        #endif
        let directory = URL.applicationSupportDirectory.appending(path: "AppKit", directoryHint: .isDirectory)
        return Location(
            storeURL: directory.appending(path: "History.store"),
            keyService: SystemEncryptionKeyService(service: "yanis-harrat.AppKit.history"),
            pasteboardName: .general,
            directPasteService: SystemDirectPasteService(),
            directPasteDefaults: .standard,
            launchAtLoginService: SystemLaunchAtLoginService(),
            soundService: SystemSoundService(),
            clipboardAccess: SystemClipboardAccessService()
        )
    }

    /// Puts a copy back on the pasteboard and moves it to the top of the history. On a failure,
    /// the pasteboard keeps what it holds.
    func restore(_ clip: Clip, style: ClipPasteStyle) async -> ClipRestoreOutcome {
        let formats = await lifecycle.formats(of: clip.id)
        let outcome = ClipRestoreOutcome.check(clip, formats: formats)
        guard outcome == .restored else { return outcome }
        await monitor.restore(clip, formats: formats, style: style)
        await lifecycle.promote(clip)
        return .restored
    }

    func start(
        onStateChange: @escaping (HistoryLifecycleState) -> Void,
        onDiscard: @escaping @MainActor @Sendable () -> Void,
        onPauseChange: @escaping () -> Void
    ) {
        pause.onChange = { [weak self] _, ignoresNext in
            self?.updateMonitorPause()
            Task { [monitor = self?.monitor] in await monitor?.ignoreNextCopy(ignoresNext) }
            onPauseChange()
        }
        lifecycle.onStateChange = { [weak self] state in
            self?.apply(state)
            onStateChange(state)
        }
        captureTask = Task { [lifecycle, monitor, weak self] in
            await monitor.setPaused(true)
            await monitor.setHandlers(
                onDiscard: {
                    Task { @MainActor in
                        self?.feedback.copyWasDiscarded()
                        onDiscard()
                    }
                },
                onIgnoredCopy: {
                    Task { @MainActor in self?.pause.ignoredCopyWentBy() }
                }
            )
            await lifecycle.open()
            Task {
                // Copies also expire while the app stays open.
                while !Task.isCancelled {
                    try? await Task.sleep(for: Motion.storagePruneInterval, tolerance: Motion.storagePruneTolerance)
                    await lifecycle.prune()
                }
            }
            for await capture in await monitor.captures() {
                await lifecycle.capture(capture)
                self?.feedback.copyWasKept()
                if case .files(let files) = capture.clip.content {
                    self?.onFilesCaptured?(files)
                }
            }
        }
    }

    func setCanReadClipboard(_ canRead: Bool) {
        canReadClipboard = canRead
        updateMonitorPause()
    }

    private func updateMonitorPause() {
        let isPaused = !capturesCopies || !canReadClipboard || pause.isPaused
        Task { [monitor] in
            await monitor.setPaused(isPaused)
        }
    }

    private func apply(_ state: HistoryLifecycleState) {
        capturesCopies = state.capturesCopies
        updateMonitorPause()
        retryTask?.cancel()
        retryTask = nil
        guard state.retriesByItself else { return }
        retryTask = Task { [lifecycle] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Motion.pausedRetryInterval, tolerance: Motion.pausedRetryTolerance)
                guard !Task.isCancelled else { return }
                await lifecycle.resumeIfPossible()
            }
        }
    }
}
