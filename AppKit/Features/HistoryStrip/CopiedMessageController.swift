import AppKit
import SwiftUI

/// Shows the brief message for a moment, above the place the strip occupied, without taking focus.
@MainActor
final class CopiedMessageController {
    private let panel = CopiedMessageController.makePanel()
    private var hideTask: Task<Void, Never>?

    /// - Parameter onEnableDirectPaste: when given, the message offers to enable direct paste.
    func show(onEnableDirectPaste: (() -> Void)? = nil) {
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(NSEvent.mouseLocation) }) ?? NSScreen.main else {
            return
        }
        hideTask?.cancel()
        panel.contentView = NSHostingView(
            rootView: CopiedMessageView(onEnableDirectPaste: onEnableDirectPaste.map { action in
                { [weak self] in
                    action()
                    self?.hide()
                }
            })
        )
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
        AccessibilityNotification.Announcement(String(localized: "Copié · faites ⌘V")).post()

        hideTask = Task { [weak self] in
            try? await Task.sleep(for: onEnableDirectPaste == nil ? Motion.briefMessageDuration : Motion.actionableMessageDuration)
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
