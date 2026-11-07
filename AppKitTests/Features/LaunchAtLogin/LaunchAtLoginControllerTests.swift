import AppKitSystem
import Foundation
import Testing
@testable import AppKitMain

@MainActor
private final class FakeLaunchAtLoginService: LaunchAtLoginService {
    var status = LaunchAtLoginStatus.disabled
    var fails = false
    private(set) var settingsOpenCount = 0

    private struct Failure: Error {}

    func enable() throws {
        if fails { throw Failure() }
        status = .enabled
    }

    func disable() throws {
        if fails { throw Failure() }
        status = .disabled
    }

    func openSystemSettings() { settingsOpenCount += 1 }
}

@MainActor
struct LaunchAtLoginControllerTests {
    private let service = FakeLaunchAtLoginService()
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "LaunchAtLoginControllerTests-\(UUID().uuidString)"))
    }

    private func makeController() -> LaunchAtLoginController {
        LaunchAtLoginController(service: service, defaults: defaults)
    }

    @Test func aChangeInSystemSettingsShowsOnRefresh() {
        let controller = makeController()
        #expect(controller.status == .disabled)
        service.status = .enabled
        controller.refresh()
        #expect(controller.status == .enabled)
    }

    @Test func enablingAndDisablingFollowMacOS() {
        let controller = makeController()
        controller.setEnabled(true)
        #expect(controller.status == .enabled)
        controller.setEnabled(false)
        #expect(controller.status == .disabled)
    }

    @Test func aFailureKeepsTheRealStateAndIsReported() {
        let controller = makeController()
        service.fails = true
        controller.setEnabled(true)
        #expect(controller.status == .disabled)
        #expect(controller.hasFailed)
    }

    @Test func theOfferComesOnceAndEnablesOnYes() {
        let controller = makeController()
        var askCount = 0
        controller.offerOnce { askCount += 1; return true }
        controller.offerOnce { askCount += 1; return true }
        #expect(askCount == 1)
        #expect(controller.status == .enabled)
    }

    @Test func laterLeavesItOffAndDoesNotAskAgain() {
        let controller = makeController()
        var askCount = 0
        controller.offerOnce { askCount += 1; return false }
        makeController().offerOnce { askCount += 1; return false }
        #expect(askCount == 1)
        #expect(controller.status == .disabled)
    }

    @Test func nothingIsOfferedWhenItIsAlreadyOn() {
        service.status = .enabled
        var askCount = 0
        makeController().offerOnce { askCount += 1; return true }
        #expect(askCount == 0)
    }
}
