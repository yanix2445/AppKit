import AppKit

/// The menu bar icon: a click opens the strip, a right click shows the menu.
@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let onPrimaryClick: () -> Void
    private let onOpenSettings: () -> Void
    private var state = HistoryLifecycleState.starting

    init(onPrimaryClick: @escaping () -> Void, onOpenSettings: @escaping () -> Void) {
        self.onPrimaryClick = onPrimaryClick
        self.onOpenSettings = onOpenSettings
        super.init()
        guard let button = statusItem.button else { return }
        button.identifier = NSUserInterfaceItemIdentifier("statusItem.button")
        button.setAccessibilityIdentifier("statusItem.button")
        button.target = self
        button.action = #selector(handleClick)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        updateImage()
    }

    /// A pause shows on the icon, because nothing else tells that copies are no longer kept.
    func setHistoryState(_ state: HistoryLifecycleState) {
        self.state = state
        updateImage()
    }

    private func updateImage() {
        let isPaused = state != .ready && state != .starting
        statusItem.button?.image = NSImage(
            systemSymbolName: isPaused ? "exclamationmark.triangle" : "clipboard",
            accessibilityDescription: pauseTitle ?? "AppKit"
        )
    }

    private var pauseTitle: String? {
        switch state {
        case .diskFull: String(localized: "Capture en pause · disque plein")
        case .keyUnavailable: String(localized: "Capture en pause · clé inaccessible")
        case .keyMissing: String(localized: "Capture en pause · clé introuvable")
        case .starting, .ready: nil
        }
    }

    private var pauseExplanation: String? {
        switch state {
        case .diskFull: String(localized: "La capture reprendra seule dès qu’il y aura de la place. Aucune copie n’est écrite à moitié.")
        case .keyUnavailable: String(localized: "La capture reprendra seule dès que la clé sera accessible. Aucune copie n’est écrite en clair.")
        case .keyMissing: String(localized: "Aucune copie n’est écrite en clair.")
        case .starting, .ready: nil
        }
    }

    @objc private func handleClick() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()
        } else {
            onPrimaryClick()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        if let pauseTitle, let pauseExplanation {
            let title = NSMenuItem(title: pauseTitle, action: nil, keyEquivalent: "")
            title.isEnabled = false
            title.setAccessibilityIdentifier("statusItem.pause")
            menu.addItem(title)
            let explanation = NSMenuItem(title: pauseExplanation, action: nil, keyEquivalent: "")
            explanation.isEnabled = false
            menu.addItem(explanation)
            if state == .diskFull {
                let freeSpace = NSMenuItem(title: String(localized: "Libérer de la place…"), action: #selector(openStorageSettings), keyEquivalent: "")
                freeSpace.target = self
                menu.addItem(freeSpace)
            }
            menu.addItem(.separator())
        }
        let open = NSMenuItem(title: String(localized: "Ouvrir l’historique"), action: #selector(openHistory), keyEquivalent: "")
        open.target = self
        menu.addItem(open)
        menu.addItem(.separator())
        let settings = NSMenuItem(title: String(localized: "Réglages…"), action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        settings.setAccessibilityIdentifier("statusItem.settings")
        menu.addItem(settings)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: String(localized: "Quitter AppKit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func openHistory() {
        onPrimaryClick()
    }

    @objc private func openSettings() {
        onOpenSettings()
    }

    @objc private func openStorageSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.settings.Storage") {
            NSWorkspace.shared.open(url)
        }
    }
}
