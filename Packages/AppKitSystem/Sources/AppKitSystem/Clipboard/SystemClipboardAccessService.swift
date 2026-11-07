import AppKit

/// Reads the setting of macOS for the general pasteboard.
@MainActor
public final class SystemClipboardAccessService: ClipboardAccessService {
    public init() {}

    public var access: ClipboardAccess {
        switch NSPasteboard.general.accessBehavior {
        case .alwaysAllow: .allowed
        case .alwaysDeny: .denied
        case .default, .ask: .asks
        @unknown default: .asks
        }
    }

    public func openSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Pasteboard") {
            NSWorkspace.shared.open(url)
        }
    }
}
