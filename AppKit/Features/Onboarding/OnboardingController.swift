import AppKit
import SwiftUI

/// Shows the first launch once, and again whenever the user asks from the settings.
@MainActor
final class OnboardingController: NSObject, NSWindowDelegate {
    static let seenKey = "onboardingSeen"

    private let defaults: UserDefaults
    private let shortcuts: ShortcutsController
    private var window: NSWindow?
    private var onFinish: (() -> Void)?

    init(defaults: UserDefaults, shortcuts: ShortcutsController) {
        self.defaults = defaults
        self.shortcuts = shortcuts
    }

    var needsShowing: Bool {
        !defaults.bool(forKey: Self.seenKey)
    }

    /// - Parameter onFinish: called when it closes, whichever way.
    func show(onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
        if let window {
            window.makeKeyAndOrderFront(nil)
            return
        }
        let view = OnboardingView(shortcuts: shortcuts) { [weak self] in
            self?.window?.close()
        }
        let controller = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: controller)
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.title = String(localized: "Bienvenue dans AppKit")
        window.isReleasedWhenClosed = false
        // At launch, macOS may leave a menu bar app behind the app in use.
        window.level = .floating
        window.delegate = self
        window.center()
        self.window = window
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        defaults.set(true, forKey: Self.seenKey)
        window = nil
        let finish = onFinish
        onFinish = nil
        finish?()
    }
}
