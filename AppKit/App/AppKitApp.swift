import SwiftUI

@main
struct AppKitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // A menu bar app has no main window; the strip and the icon belong to AppDelegate.
        Settings {
            EmptyView()
        }
    }
}
