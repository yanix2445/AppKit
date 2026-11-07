import AppKitCore
import AppKitSystem
import Foundation
import Testing
@testable import AppKitMain

private final class StubClipboardAccessService: ClipboardAccessService {
    var access = ClipboardAccess.allowed
    func openSettings() {}
}

private final class StubDirectPasteService: DirectPasteService {
    var isTrusted = false
    func focusedTarget() -> DirectPasteTarget { .editable }
    func postPaste() {}
    func openAccessibilitySettings() {}
}

private final class StubLaunchAtLoginService: LaunchAtLoginService {
    var status = LaunchAtLoginStatus.disabled
    func enable() throws { status = .enabled }
    func disable() throws { status = .disabled }
    func openSystemSettings() {}
}

@MainActor
struct PermissionsControllerTests {
    private let clipboard = StubClipboardAccessService()
    private let directPaste = StubDirectPasteService()
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "PermissionsControllerTests-\(UUID().uuidString)"))
    }

    private func makeController() -> PermissionsController {
        PermissionsController(
            directPaste: directPaste,
            clipboard: clipboard,
            launchAtLogin: LaunchAtLoginController(service: StubLaunchAtLoginService(), defaults: defaults),
            defaults: defaults
        )
    }

    @Test func aRefreshReadsTheStatesAgain() {
        let controller = makeController()
        #expect(controller.accessibilityStatus == .toGrant)
        #expect(controller.clipboardStatus == .granted)
        #expect(controller.launchAtLoginStatus == .toGrant)

        directPaste.isTrusted = true
        clipboard.access = .denied
        controller.refresh()
        #expect(controller.accessibilityStatus == .granted)
        #expect(controller.clipboardStatus == .denied)
    }

    @Test func aChangeOfThePasteboardAccessIsToldOnce() {
        let controller = makeController()
        var changes: [ClipboardAccess] = []
        controller.onClipboardAccessChange = { changes.append($0) }
        controller.refresh()
        #expect(changes.isEmpty)
        clipboard.access = .denied
        controller.refresh()
        controller.refresh()
        #expect(changes == [.denied])
    }

    @Test func theReadingIsExplainedOnceAndOnlyWhenMacOSAsks() {
        #expect(!makeController().shouldExplainClipboard)
        clipboard.access = .asks
        let controller = makeController()
        #expect(controller.shouldExplainClipboard)
        controller.markClipboardExplained()
        #expect(!makeController().shouldExplainClipboard)
        clipboard.access = .denied
        defaults.removeObject(forKey: PermissionsController.clipboardExplanationSeenKey)
        #expect(!makeController().shouldExplainClipboard)
    }
}
