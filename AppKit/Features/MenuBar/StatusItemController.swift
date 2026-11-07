import AppKit
import AppKitCore
import AppKitSystem

/// The menu bar icon: a click opens the strip, a right click shows the menu.
@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let copyCount: () -> Int
    private let launchAtLogin: LaunchAtLoginController
    private let pause: CapturePauseController
    private let onPrimaryClick: () -> Void
    private let onOpenSettings: () -> Void
    private var state = HistoryLifecycleState.starting
    private var openHistoryHotKey: HotKeyCombination?

    init(
        copyCount: @escaping () -> Int,
        launchAtLogin: LaunchAtLoginController,
        pause: CapturePauseController,
        onPrimaryClick: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.copyCount = copyCount
        self.launchAtLogin = launchAtLogin
        self.pause = pause
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

    /// The pause the user asked for has changed.
    func capturePauseDidChange() {
        updateImage()
    }

    /// A brief fade of the icon when a rule refuses a copy, without anything of its content.
    func flashDiscardedCopy() {
        guard let button = statusItem.button else { return }
        button.setAccessibilityValue(String(localized: "Copie écartée"))
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Motion.discardFlash
            button.animator().alphaValue = StripMetrics.discardFlashOpacity
        }, completionHandler: {
            MainActor.assumeIsolated {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = Motion.discardFlash
                    button.animator().alphaValue = 1
                }
            }
        })
        Task {
            try? await Task.sleep(for: Motion.briefMessageDuration)
            button.setAccessibilityValue(nil)
        }
    }

    /// Shown next to the menu entry, as a reminder.
    func setOpenHistoryHotKey(_ combination: HotKeyCombination?) {
        openHistoryHotKey = combination
    }

    private func updateImage() {
        let name: String
        if pauseTitle != nil {
            name = "MenuBarIconAlert"
        } else if pause.statusText != nil {
            name = "MenuBarIconPaused"
        } else {
            name = "MenuBarIcon"
        }
        let image = NSImage(named: name)
        image?.isTemplate = true
        image?.accessibilityDescription = pauseTitle ?? userPauseTitle ?? "AppKit"
        statusItem.button?.image = image
    }

    private var userPauseTitle: String? { pause.statusText }

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
        launchAtLogin.refresh()
        let menu = NSMenu()
        menu.autoenablesItems = false
        addHeader(to: menu)
        addLaunchAtLoginNotice(to: menu)

        let open = NSMenuItem(title: String(localized: "Ouvrir l’historique"), action: #selector(openHistory), keyEquivalent: "")
        open.target = self
        if let openHistoryHotKey {
            open.keyEquivalent = openHistoryHotKey.character.lowercased()
            open.keyEquivalentModifierMask = Self.eventModifiers(openHistoryHotKey.modifiers)
        }
        menu.addItem(open)
        menu.addItem(makePauseItem())
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

    private func makePauseItem() -> NSMenuItem {
        if pause.statusText != nil {
            let resume = NSMenuItem(title: String(localized: "Reprendre"), action: #selector(resumeCapture), keyEquivalent: "")
            resume.target = self
            resume.setAccessibilityIdentifier("statusItem.resume")
            return resume
        }
        let item = NSMenuItem(title: String(localized: "Mettre en pause"), action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        submenu.addItem(pauseEntry(String(localized: "Pendant 5 minutes"), #selector(pauseFiveMinutes), "statusItem.pause5"))
        submenu.addItem(pauseEntry(String(localized: "Pendant 1 heure"), #selector(pauseOneHour), "statusItem.pause60"))
        submenu.addItem(pauseEntry(String(localized: "Jusqu’à réactivation"), #selector(pauseUntilResumed), "statusItem.pauseForever"))
        submenu.addItem(pauseEntry(String(localized: "Ignorer la prochaine copie"), #selector(ignoreNextCopy), "statusItem.ignoreNext"))
        item.submenu = submenu
        item.setAccessibilityIdentifier("statusItem.pauseMenu")
        return item
    }

    private func pauseEntry(_ title: String, _ action: Selector, _ identifier: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.setAccessibilityIdentifier(identifier)
        return item
    }

    @objc private func pauseFiveMinutes() { pause.pause(for: 300) }
    @objc private func pauseOneHour() { pause.pause(for: 3_600) }
    @objc private func pauseUntilResumed() { pause.pauseUntilResumed() }
    @objc private func ignoreNextCopy() { pause.ignoreNextCopy() }
    @objc private func resumeCapture() { pause.resume() }

    private func addHeader(to menu: NSMenu) {
        menu.addItem(disabledItem("AppKit"))
        if let pauseTitle, let pauseExplanation {
            let title = disabledItem(pauseTitle)
            title.setAccessibilityIdentifier("statusItem.pause")
            menu.addItem(title)
            menu.addItem(disabledItem(pauseExplanation))
            if state == .diskFull {
                let freeSpace = NSMenuItem(title: String(localized: "Libérer de la place…"), action: #selector(openStorageSettings), keyEquivalent: "")
                freeSpace.target = self
                menu.addItem(freeSpace)
            }
        } else if let userPauseTitle {
            let title = disabledItem(userPauseTitle)
            title.setAccessibilityIdentifier("statusItem.userPause")
            menu.addItem(title)
        } else {
            menu.addItem(disabledItem(String(localized: "Capture active · \(copyCount()) copies")))
        }
        menu.addItem(.separator())
    }

    /// The discreet signal when copies would be missed after a restart.
    private func addLaunchAtLoginNotice(to menu: NSMenu) {
        guard launchAtLogin.status != .enabled else { return }
        let notice = disabledItem(String(localized: "Le lancement à l’ouverture de session est désactivé."))
        notice.setAccessibilityIdentifier("statusItem.launchAtLoginNotice")
        menu.addItem(notice)
        let enable = NSMenuItem(title: String(localized: "Activer le lancement automatique"), action: #selector(enableLaunchAtLogin), keyEquivalent: "")
        enable.target = self
        menu.addItem(enable)
        menu.addItem(.separator())
    }

    private func disabledItem(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private static func eventModifiers(_ modifiers: HotKeyModifiers) -> NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if modifiers.contains(.command) { flags.insert(.command) }
        if modifiers.contains(.shift) { flags.insert(.shift) }
        if modifiers.contains(.option) { flags.insert(.option) }
        if modifiers.contains(.control) { flags.insert(.control) }
        return flags
    }

    @objc private func openHistory() {
        onPrimaryClick()
    }

    @objc private func openSettings() {
        onOpenSettings()
    }

    @objc private func enableLaunchAtLogin() {
        launchAtLogin.setEnabled(true)
        if launchAtLogin.status == .requiresApproval {
            launchAtLogin.openSystemSettings()
        }
    }

    @objc private func openStorageSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.settings.Storage") {
            NSWorkspace.shared.open(url)
        }
    }
}
