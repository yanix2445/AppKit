import AppKit
import AppKitSystem
import Foundation
import Observation

/// The state of what AppKit needs from macOS, read again whenever the user may have changed it.
@Observable
final class PermissionsController {
    static let clipboardExplanationSeenKey = "clipboardExplanationSeen"

    private let directPaste: any DirectPasteService
    private let clipboard: any ClipboardAccessService
    private let launchAtLogin: LaunchAtLoginController
    private let defaults: UserDefaults
    private var activationObserver: NSObjectProtocol?

    private(set) var clipboardAccess: ClipboardAccess
    private(set) var isAccessibilityTrusted: Bool

    /// Told when macOS starts or stops letting AppKit read the pasteboard.
    var onClipboardAccessChange: ((ClipboardAccess) -> Void)?

    init(
        directPaste: any DirectPasteService,
        clipboard: any ClipboardAccessService,
        launchAtLogin: LaunchAtLoginController,
        defaults: UserDefaults
    ) {
        self.directPaste = directPaste
        self.clipboard = clipboard
        self.launchAtLogin = launchAtLogin
        self.defaults = defaults
        clipboardAccess = clipboard.access
        isAccessibilityTrusted = directPaste.isTrusted
    }

    /// Back from System Settings, the app comes forward again.
    func startObserving() {
        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }

    func refresh() {
        launchAtLogin.refresh()
        isAccessibilityTrusted = directPaste.isTrusted
        let access = clipboard.access
        if access != clipboardAccess {
            clipboardAccess = access
            onClipboardAccessChange?(access)
        }
    }

    var clipboardStatus: PermissionStatus {
        switch clipboardAccess {
        case .allowed: .granted
        case .asks: .toGrant
        case .denied: .denied
        }
    }

    var accessibilityStatus: PermissionStatus {
        isAccessibilityTrusted ? .granted : .toGrant
    }

    var launchAtLoginStatus: PermissionStatus {
        launchAtLogin.status == .enabled ? .granted : .toGrant
    }

    /// Only once, and only when macOS itself will not stay silent about the reading.
    var shouldExplainClipboard: Bool {
        clipboardAccess == .asks && !defaults.bool(forKey: Self.clipboardExplanationSeenKey)
    }

    func markClipboardExplained() {
        defaults.set(true, forKey: Self.clipboardExplanationSeenKey)
    }

    func openClipboardSettings() { clipboard.openSettings() }
    func openAccessibilitySettings() { directPaste.openAccessibilitySettings() }
    func openLaunchAtLoginSettings() { launchAtLogin.openSystemSettings() }
}
