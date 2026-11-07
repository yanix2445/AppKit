import AppKit
import SwiftUI

/// Opens the settings window. A menu bar app has no SwiftUI view from which to open the `Settings`
/// scene, because the menu of its icon is an `NSMenu`.
@MainActor
final class SettingsWindowController {
    private let navigation = SettingsNavigation()
    private let launchAtLogin: LaunchAtLoginController
    private let shortcuts: ShortcutsController
    private let permissions: PermissionsController
    private let storage: StorageSettingsViewModel
    private let defaults: UserDefaults
    private let feedback: CopyFeedbackController
    private lazy var window = makeWindow()

    init(
        launchAtLogin: LaunchAtLoginController,
        shortcuts: ShortcutsController,
        permissions: PermissionsController,
        lifecycle: HistoryLifecycle,
        defaults: UserDefaults,
        feedback: CopyFeedbackController
    ) {
        self.launchAtLogin = launchAtLogin
        self.shortcuts = shortcuts
        self.permissions = permissions
        storage = StorageSettingsViewModel(lifecycle: lifecycle, defaults: defaults)
        self.defaults = defaults
        self.feedback = feedback
    }

    func show(_ pane: SettingsPane? = nil) {
        if let pane {
            navigation.show(pane)
        }
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let view = SettingsView(
            navigation: navigation,
            launchAtLogin: launchAtLogin,
            shortcuts: shortcuts,
            permissions: permissions,
            storage: storage,
            defaults: defaults,
            feedback: feedback
        ).defaultAppStorage(defaults)
        let controller = NSHostingController(rootView: view)
        // The window takes the size of the mockups, and stays resizable down to the minimum.
        controller.sizingOptions = .minSize
        let window = NSWindow(contentViewController: controller)
        window.title = String(localized: "Réglages")
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        let visible = NSScreen.main?.visibleFrame.size ?? NSSize(width: SettingsMetrics.width, height: SettingsMetrics.height)
        window.setContentSize(NSSize(
            width: min(SettingsMetrics.width, visible.width),
            height: min(SettingsMetrics.height, visible.height)
        ))
        window.center()
        return window
    }
}
