import AppKit
import AppKitCore
import Foundation
import SwiftUI

/// Opens and closes the strip at the bottom of the screen, over the Dock.
@MainActor
final class HistoryStripController {
    private let viewModel: HistoryStripViewModel
    private let appearanceProvider = SourceAppAppearanceProvider()
    private let thumbnailProvider: ClipThumbnailProvider
    private lazy var panel = makePanel()
    private var clickMonitor: Any?
    private var pause: CapturePauseController?
    private var activationObserver: NSObjectProtocol?
    private var openedAt = ContinuousClock.now

    private(set) var isOpen = false

    /// - Parameter onChoose: called with the copy the user picks; the strip then closes.
    init(
        history: ClipHistory,
        loadThumbnail: @escaping (Clip.ID) async -> Data? = { _ in nil },
        onChoose: @escaping (Clip, ClipPasteStyle) -> Void
    ) {
        viewModel = HistoryStripViewModel(history: history, onChoose: onChoose)
        thumbnailProvider = ClipThumbnailProvider(load: loadThumbnail)
    }

    /// The shortcut that opens the strip, which the empty strip mentions.
    func setOpenHotKey(_ combination: HotKeyCombination?) {
        viewModel.openHotKey = combination
    }

    func setPause(_ pause: CapturePauseController) {
        self.pause = pause
        viewModel.onResume = { [weak pause] in pause?.resume() }
        pauseDidChange()
    }

    /// The banner comes and goes, and the strip makes room for it.
    func pauseDidChange() {
        viewModel.pauseBanner = pause.flatMap(Self.bannerText)
        if isOpen, let screen = panel.screen {
            panel.setFrame(openFrame(on: screen), display: true)
        }
    }

    private static func bannerText(_ pause: CapturePauseController) -> String? {
        switch pause.pause {
        case .until(let end) where pause.isPaused:
            String(localized: "Capture en pause jusqu’à \(end.formatted(date: .omitted, time: .shortened))")
        case .untilResumed:
            String(localized: "Capture en pause jusqu’à réactivation")
        default:
            nil
        }
    }

    private func openFrame(on screen: NSScreen) -> NSRect {
        let banner = viewModel.pauseBanner == nil ? 0 : StripMetrics.pauseBannerHeight
        return NSRect(
            x: screen.frame.minX + StripMetrics.screenMargin,
            y: screen.frame.minY + StripMetrics.screenMargin,
            width: screen.frame.width - 2 * StripMetrics.screenMargin,
            height: StripMetrics.stripHeight + banner
        )
    }

    func toggle() {
        isOpen ? close() : open()
    }

    func open() {
        guard !isOpen, let screen = screenUnderMouse else { return }
        isOpen = true
        openedAt = .now
        viewModel.prepareForPresentation()

        let frame = openFrame(on: screen)
        panel.setFrame(hiddenFrame(from: frame), display: false)
        panel.makeKeyAndOrderFront(nil)
        animate(to: frame)

        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            MainActor.assumeIsolated { self?.close() }
        }
        // ⌘Tab and an app coming forward by itself are not clicks, but they end the strip too.
        activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            let isOtherApp = app?.processIdentifier != ProcessInfo.processInfo.processIdentifier
            // An app switch still under way as the strip opens, right after ⌘Tab, must not close it.
            MainActor.assumeIsolated {
                guard let self, isOtherApp, ContinuousClock.now - self.openedAt > Motion.stripActivationGrace else { return }
                self.close()
            }
        }
    }

    func close() {
        guard isOpen else { return }
        isOpen = false
        thumbnailProvider.releaseAll()
        if let clickMonitor {
            NSEvent.removeMonitor(clickMonitor)
            self.clickMonitor = nil
        }
        if let activationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(activationObserver)
            self.activationObserver = nil
        }
        animate(to: hiddenFrame(from: panel.frame)) { [weak self] in
            // The strip may have been reopened during the slide.
            guard let self, !self.isOpen else { return }
            self.panel.orderOut(nil)
        }
    }

    /// Leaves the screen at once, so that the keyboard goes back to the app for the paste.
    func closeImmediately() {
        guard isOpen else { return }
        close()
        panel.orderOut(nil)
    }

    private var screenUnderMouse: NSScreen? {
        NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) } ?? NSScreen.main
    }

    private func hiddenFrame(from frame: NSRect) -> NSRect {
        frame.offsetBy(dx: 0, dy: -(frame.height + StripMetrics.screenMargin))
    }

    private func animate(to frame: NSRect, completion: (@MainActor @Sendable () -> Void)? = nil) {
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            panel.setFrame(frame, display: true)
            completion?()
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Motion.stripSlide
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrame(frame, display: true)
        } completionHandler: {
            if let completion {
                MainActor.assumeIsolated { completion() }
            }
        }
    }

    private func makePanel() -> HistoryStripPanel {
        let panel = HistoryStripPanel()
        panel.onCancel = { [weak self] in self?.close() }
        panel.contentView = NSHostingView(
            rootView: HistoryStripView(
                viewModel: viewModel,
                appearanceProvider: appearanceProvider,
                thumbnailProvider: thumbnailProvider,
                close: { [weak self] in self?.close() }
            )
        )
        return panel
    }
}
