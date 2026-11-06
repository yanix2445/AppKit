import AppKit

/// The menu bar icon: a click opens the strip, a right click shows the menu.
@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let onPrimaryClick: () -> Void

    init(onPrimaryClick: @escaping () -> Void) {
        self.onPrimaryClick = onPrimaryClick
        super.init()
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "AppKit")
        button.identifier = NSUserInterfaceItemIdentifier("statusItem.button")
        button.setAccessibilityIdentifier("statusItem.button")
        button.target = self
        button.action = #selector(handleClick)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
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
        let open = NSMenuItem(title: String(localized: "Ouvrir l’historique"), action: #selector(openHistory), keyEquivalent: "")
        open.target = self
        menu.addItem(open)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: String(localized: "Quitter AppKit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func openHistory() {
        onPrimaryClick()
    }
}
