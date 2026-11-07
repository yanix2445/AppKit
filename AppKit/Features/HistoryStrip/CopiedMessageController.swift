import AppKit
import SwiftUI

/// Shows the brief message for a moment, above the place the strip occupied, without taking focus.
@MainActor
final class CopiedMessageController {
    private let panel = CopiedMessageController.makePanel()
    private var hideTask: Task<Void, Never>?

    /// - Parameter onEnableDirectPaste: when given, the message offers to enable direct paste.
    func show(onEnableDirectPaste: (() -> Void)? = nil) {
        present(
            CopiedMessageView(content: .copied(onEnableDirectPaste: onEnableDirectPaste.map { action in
                { [weak self] in
                    action()
                    self?.hide()
                }
            })),
            announcement: String(localized: "Copié · faites ⌘V"),
            duration: onEnableDirectPaste == nil ? Motion.briefMessageDuration : Motion.actionableMessageDuration
        )
    }

    /// Says why a chosen copy did not come back.
    func showFailure(_ text: String) {
        present(
            CopiedMessageView(content: .failure(text)),
            announcement: text,
            duration: Motion.actionableMessageDuration
        )
    }

    private func present(_ view: CopiedMessageView, announcement: String, duration: Duration) {
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(NSEvent.mouseLocation) }) ?? NSScreen.main else {
            return
        }
        hideTask?.cancel()
        panel.contentView = NSHostingView(rootView: view)
        panel.setFrame(
            NSRect(
                x: screen.frame.midX - StripMetrics.briefMessageWidth / 2,
                y: screen.frame.minY + StripMetrics.briefMessageBottomOffset,
                width: StripMetrics.briefMessageWidth,
                height: StripMetrics.briefMessageHeight
            ),
            display: false
        )
        panel.alphaValue = 1
        panel.orderFrontRegardless()
        AccessibilityNotification.Announcement(announcement).post()

        hideTask = Task { [weak self] in
            try? await Task.sleep(for: duration)
            guard !Task.isCancelled else { return }
            self?.hide()
        }
    }

    private func hide() {
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            panel.orderOut(nil)
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Motion.briefMessageFade
            panel.animator().alphaValue = 0
        } completionHandler: { [panel] in
            MainActor.assumeIsolated { panel.orderOut(nil) }
        }
    }

    private static func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.level = .statusBar
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        return panel
    }
}
