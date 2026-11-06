import AppKit
import AppKitCore
import SwiftUI

/// Opens and closes the strip at the bottom of the screen, over the Dock.
@MainActor
final class HistoryStripController {
    private let viewModel: HistoryStripViewModel
    private let appearanceProvider = SourceAppAppearanceProvider()
    private lazy var panel = makePanel()
    private var clickMonitor: Any?
    private var resignKeyObserver: NSObjectProtocol?

    private(set) var isOpen = false

    /// - Parameter onChoose: called with the copy the user picks; the strip then closes.
    init(history: ClipHistory, onChoose: @escaping (Clip) -> Void) {
        viewModel = HistoryStripViewModel(history: history, onChoose: onChoose)
    }

    func toggle() {
        isOpen ? close() : open()
    }

    func open() {
        guard !isOpen, let screen = screenUnderMouse else { return }
        isOpen = true
        viewModel.prepareForPresentation()

        let frame = NSRect(
            x: screen.frame.minX + StripMetrics.screenMargin,
            y: screen.frame.minY + StripMetrics.screenMargin,
            width: screen.frame.width - 2 * StripMetrics.screenMargin,
            height: StripMetrics.stripHeight
        )
        panel.setFrame(hiddenFrame(from: frame), display: false)
        panel.makeKeyAndOrderFront(nil)
        animate(to: frame)

        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            MainActor.assumeIsolated { self?.close() }
        }
        // A click elsewhere can also reach the strip as a loss of the keyboard.
        resignKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.close() }
        }
    }

    func close() {
        guard isOpen else { return }
        isOpen = false
        if let clickMonitor {
            NSEvent.removeMonitor(clickMonitor)
            self.clickMonitor = nil
        }
        if let resignKeyObserver {
            NotificationCenter.default.removeObserver(resignKeyObserver)
            self.resignKeyObserver = nil
        }
        animate(to: hiddenFrame(from: panel.frame)) { [weak self] in
            // The strip may have been reopened during the slide.
            guard let self, !self.isOpen else { return }
            self.panel.orderOut(nil)
        }
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
                close: { [weak self] in self?.close() }
            )
        )
        return panel
    }
}
