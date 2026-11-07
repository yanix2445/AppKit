import AppKit
import SwiftUI

/// Opens the settings window. A menu bar app has no SwiftUI view from which to open the `Settings`
/// scene, because the menu of its icon is an `NSMenu`.
@MainActor
final class SettingsWindowController {
    private let launchAtLogin: LaunchAtLoginController
    private lazy var window = makeWindow()

    private let storage: StorageSettingsViewModel
    private let defaults: UserDefaults

    init(launchAtLogin: LaunchAtLoginController, lifecycle: HistoryLifecycle, defaults: UserDefaults) {
        self.launchAtLogin = launchAtLogin
        storage = StorageSettingsViewModel(lifecycle: lifecycle, defaults: defaults)
        self.defaults = defaults
    }

    func show() {
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(launchAtLogin: launchAtLogin, storage: storage).defaultAppStorage(defaults)))
        window.title = String(localized: "Réglages")
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}
