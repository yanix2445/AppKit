import AppKit
import AppKitCore
import AppKitSystem
import SwiftUI

/// Starts what a menu bar app needs before any scene appears.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var dependencies: AppDependencies?
    private var historyStrip: HistoryStripController?
    private var statusItem: StatusItemController?
    private let copiedMessage = CopiedMessageController()
    private var settings: SettingsWindowController?
    private let launchAtLoginAlert = LaunchAtLoginAlertPresenter()
    private let recovery = HistoryRecoveryAlertPresenter()
    private let hotKeyConflict = HotKeyConflictAlertPresenter()
    private var globalHotKey: GlobalHotKeyController?
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
        settings = SettingsWindowController(launchAtLogin: dependencies.launchAtLogin, lifecycle: dependencies.lifecycle, defaults: dependencies.directPasteDefaults)
        directPaste = DirectPasteCoordinator(
            service: dependencies.directPasteService,
            defaults: dependencies.directPasteDefaults,
            askToOpenSettings: { [directPasteAlert] in directPasteAlert.askToOpenSettings() }
        )

        let lifecycle = dependencies.lifecycle
        let historyStrip = HistoryStripController(
            history: dependencies.history,
            loadThumbnail: { await lifecycle.thumbnail(of: $0) }
        ) { [weak self] clip, style in
            self?.restore(clip, style: style)
        }
        self.historyStrip = historyStrip
        let history = dependencies.history
        statusItem = StatusItemController(
            copyCount: { history.clips.count },
            launchAtLogin: dependencies.launchAtLogin,
            onPrimaryClick: { historyStrip.toggle() },
            onOpenSettings: { [weak self] in self?.settings?.show() }
        )
        dependencies.onFilesCaptured = { [protectedFolderAlert] files in
            protectedFolderAlert.explainIfNeeded(for: files)
        }
        dependencies.start { [weak self] state in
            self?.handle(state)
        }
        startGlobalHotKey(historyStrip: historyStrip)
        // Past launch, as the offer runs modally.
        Task { [launchAtLoginAlert, launchAtLogin = dependencies.launchAtLogin] in
            launchAtLogin.offerOnce { launchAtLoginAlert.askToEnable() }
        }
    }

    private func startGlobalHotKey(historyStrip: HistoryStripController) {
        let globalHotKey = GlobalHotKeyController(
            service: SystemHotKeyService(),
            onTrigger: { historyStrip.toggle() },
            askForFallback: { [hotKeyConflict] taken, fallbacks in
                hotKeyConflict.askForFallback(taken: taken, fallbacks: fallbacks)
            }
        )
        self.globalHotKey = globalHotKey
        // Past launch, as the alert about a taken shortcut runs modally.
        Task { [weak self] in
            globalHotKey.start()
            historyStrip.setOpenHotKey(globalHotKey.registered)
            self?.statusItem?.setOpenHistoryHotKey(globalHotKey.registered)
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
