import AppKit

/// A panel that takes the keyboard without activating AppKit, so the app in front keeps its focus.
final class HistoryStripPanel: NSPanel {
    var onCancel: (() -> Void)?
    /// Sees each key before the search field, which would otherwise keep the arrows and Return.
    var onKeyDown: ((NSEvent) -> Bool)?

    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        isFloatingPanel = true
        level = .statusBar // Above the Dock, which the strip covers.
        hidesOnDeactivate = false
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown, !isComposingText, onKeyDown?(event) == true {
            return
        }
        super.sendEvent(event)
    }

    /// The keys with ⌘ come here first, before the menu of the app can take them, such as ⌘Z.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if !isComposingText, onKeyDown?(event) == true {
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    /// While an input method composes a character, its keys belong to it.
    private var isComposingText: Bool {
        (firstResponder as? NSTextView)?.hasMarkedText() == true
    }

    override func cancelOperation(_ sender: Any?) {
        onCancel?()
    }
}
