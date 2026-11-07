import AppKit
import AppKitCore
import AppKitSystem
import SwiftUI

/// Starts what a menu bar app needs before any scene appears.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var dependencies: AppDependencies?
    private var historyStrip: HistoryStripController?
    private var permissions: PermissionsController?
    private var shortcuts: ShortcutsController?
    private let clipboardAlert = ClipboardAccessAlertPresenter()
    private var hasExplainedRefusal = false
    private var statusItem: StatusItemController?
    private let copiedMessage = CopiedMessageController()
    private var settings: SettingsWindowController?
    private let launchAtLoginAlert = LaunchAtLoginAlertPresenter()
    private let recovery = HistoryRecoveryAlertPresenter()
    private let hotKeyConflict = HotKeyConflictAlertPresenter()
    private let directPasteAlert = DirectPasteAlertPresenter()
    private var directPaste: DirectPasteCoordinator?
    private let protectedFolderAlert = ProtectedFolderAlertPresenter()

    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        guard !UITestEnvironment.isHostingUnitTests else { return }
        #endif
        guard let dependencies = try? AppDependencies() else {
            NSApp.terminate(nil)
            return
        }
        self.dependencies = dependencies
        let permissions = PermissionsController(
            directPaste: dependencies.directPasteService,
            clipboard: dependencies.clipboardAccess,
            launchAtLogin: dependencies.launchAtLogin,
            defaults: dependencies.directPasteDefaults
        )
        self.permissions = permissions
        directPaste = DirectPasteCoordinator(
            service: dependencies.directPasteService,
            defaults: dependencies.directPasteDefaults,
            askToOpenSettings: { [directPasteAlert] in directPasteAlert.askToOpenSettings() }
        )

        let lifecycle = dependencies.lifecycle
        let historyStrip = HistoryStripController(
            history: dependencies.history,
            loadThumbnail: { await lifecycle.thumbnail(of: $0) },
            actions: HistoryStripActions(
                togglePin: { id in Task { await lifecycle.togglePin(id) } },
                movePinned: { id, place in Task { await lifecycle.movePinned(id, to: place) } },
                remove: { lifecycle.remove($0) },
                undoRemoval: { lifecycle.undoRemoval() },
                commitRemovals: { Task { await lifecycle.commitRemovals() } },
                openSettings: { [weak self] in self?.settings?.show() },
                quit: { NSApp.terminate(nil) }
            )
        ) { [weak self] clip, style in
            self?.restore(clip, style: style)
        }
        self.historyStrip = historyStrip
        let pause = dependencies.pause
        let shortcuts = makeShortcuts(dependencies: dependencies, historyStrip: historyStrip, pause: pause)
        self.shortcuts = shortcuts
        historyStrip.setShortcuts(shortcuts)
        settings = SettingsWindowController(
            launchAtLogin: dependencies.launchAtLogin,
            shortcuts: shortcuts,
            permissions: permissions,
            lifecycle: dependencies.lifecycle,
            defaults: dependencies.directPasteDefaults,
            feedback: dependencies.feedback
        )
        let history = dependencies.history
        statusItem = StatusItemController(
            copyCount: { history.clips.count },
            launchAtLogin: dependencies.launchAtLogin,
            pause: pause,
            shortcuts: shortcuts,
            onPrimaryClick: { historyStrip.toggle() },
            onOpenSettings: { [weak self] in self?.settings?.show() },
            onOpenClipboardSettings: { permissions.openClipboardSettings() }
        )
        dependencies.onFilesCaptured = { [protectedFolderAlert] files in
            protectedFolderAlert.explainIfNeeded(for: files)
        }
        historyStrip.setPause(pause)
        dependencies.start(
            onStateChange: { [weak self] state in self?.handle(state) },
            onDiscard: { [weak self] in self?.statusItem?.flashDiscardedCopy() },
            onPauseChange: { [weak self] in
                self?.statusItem?.capturePauseDidChange()
            }
        )
        statusItem?.capturePauseDidChange()
        permissions.onClipboardAccessChange = { [weak self] _ in self?.applyClipboardAccess() }
        permissions.startObserving()
        // Past launch, as these explanations run modally.
        Task { [weak self, launchAtLoginAlert, launchAtLogin = dependencies.launchAtLogin] in
            self?.resolveClipboardAccess()
            shortcuts.start()
            launchAtLogin.offerOnce { launchAtLoginAlert.askToEnable() }
        }
    }

    private func makeShortcuts(
        dependencies: AppDependencies,
        historyStrip: HistoryStripController,
        pause: CapturePauseController
    ) -> ShortcutsController {
        let defaults = dependencies.directPasteDefaults
        return ShortcutsController(
            defaults: defaults,
            openHistory: GlobalHotKeyController(
                action: .openHistory,
                service: SystemHotKeyService(),
                defaults: defaults,
                onTrigger: { historyStrip.toggle() },
                askForFallback: { [hotKeyConflict] taken, fallbacks in
                    hotKeyConflict.askForFallback(taken: taken, fallbacks: fallbacks)
                }
            ),
            togglePause: GlobalHotKeyController(
                action: .togglePause,
                service: SystemHotKeyService(),
                defaults: defaults,
                onTrigger: {
                    if pause.statusText == nil {
                        pause.pauseUntilResumed()
                    } else {
                        pause.resume()
                    }
                }
            )
        )
    }

    /// The first time, says why before macOS asks; « Pas maintenant » leaves capture in pause.
    private func resolveClipboardAccess() {
        guard let permissions, let dependencies else { return }
        if permissions.shouldExplainClipboard {
            permissions.markClipboardExplained()
            if !clipboardAlert.explainReading() {
                dependencies.pause.pauseUntilResumed()
            }
        }
        applyClipboardAccess()
    }

    private func applyClipboardAccess() {
        guard let permissions, let dependencies else { return }
        let isDenied = permissions.clipboardAccess == .denied
        dependencies.setCanReadClipboard(!isDenied)
        statusItem?.setClipboardDenied(isDenied)
        if isDenied, !hasExplainedRefusal {
            hasExplainedRefusal = true
            if clipboardAlert.explainRefusal() {
                permissions.openClipboardSettings()
            }
        }
    }

    private func handle(_ state: HistoryLifecycleState) {
        statusItem?.setHistoryState(state)
        guard state == .keyMissing else { return }
        // Past the current run of the state change, as the alert runs modally.
        Task {
            await resolveMissingKey()
        }
    }

    private func resolveMissingKey() async {
        guard let lifecycle = dependencies?.lifecycle else { return }
        while lifecycle.state == .keyMissing {
            switch recovery.askForChoice() {
            case .retry:
                await lifecycle.open()
            case .startOver:
                await lifecycle.startOver()
            }
        }
    }

    /// A copy removed just before quitting must still leave the disk.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        historyStrip?.closeImmediately()
        guard let lifecycle = dependencies?.lifecycle, lifecycle.hasRemovals else { return .terminateNow }
        Task {
            await lifecycle.commitRemovals()
            sender.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    private func restore(_ clip: Clip, style: ClipPasteStyle) {
        historyStrip?.closeImmediately()
        Task {
            switch await dependencies?.restore(clip, style: style) {
            case .restored:
                await deliver()
            case .filesMissing:
                copiedMessage.showFailure(String(localized: "Fichier déplacé ou supprimé"))
            case .unreadable:
                copiedMessage.showFailure(String(localized: "Cette copie n’a pas pu être relue"))
            case nil:
                break
            }
        }
    }

    private func deliver() async {
        switch await directPaste?.deliver() {
        case .copied(let offersEnabling):
            let directPaste = self.directPaste
            copiedMessage.show(onEnableDirectPaste: offersEnabling ? { directPaste?.enable() } : nil)
        case .pasted:
            AccessibilityNotification.Announcement(String(localized: "Collé")).post()
        case nil:
            break
        }
    }
}
