import AppKitSystem
import Foundation
import Testing
@testable import AppKitMain

@MainActor
private final class FakeDirectPasteService: DirectPasteService {
    var isTrusted = false
    var target = DirectPasteTarget.editable
    private(set) var pasteCount = 0
    private(set) var settingsOpenCount = 0

    func focusedTarget() -> DirectPasteTarget { target }
    func postPaste() { pasteCount += 1 }
    func openAccessibilitySettings() { settingsOpenCount += 1 }
}

@MainActor
struct DirectPasteCoordinatorTests {
    private let service = FakeDirectPasteService()
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "DirectPasteCoordinatorTests-\(UUID().uuidString)"))
    }

    private func makeCoordinator(
        focusReturnDelay: Duration = .zero,
        askToOpenSettings: @escaping () -> Bool = { false }
    ) -> DirectPasteCoordinator {
        DirectPasteCoordinator(
            service: service,
            defaults: defaults,
            focusReturnDelay: focusReturnDelay,
            askToOpenSettings: askToOpenSettings
        )
    }

    @Test(arguments: [DirectPasteTarget.editable, .unknown])
    func withThePermissionItPastes(target: DirectPasteTarget) async {
        service.isTrusted = true
        service.target = target
        #expect(await makeCoordinator().deliver() == .pasted)
        #expect(service.pasteCount == 1)
    }

    @Test func withoutAFieldTheCopyStaysOnThePasteboard() async {
        service.isTrusted = true
        service.target = .notEditable
        #expect(await makeCoordinator().deliver() == .copied(offersEnabling: false))
        #expect(service.pasteCount == 0)
    }

    @Test func withoutThePermissionItOffersToEnableIt() async {
        #expect(await makeCoordinator().deliver() == .copied(offersEnabling: true))
        #expect(service.pasteCount == 0)
    }

    @Test func theExplanationComesOnlyOnce() async {
        var askCount = 0
        let coordinator = makeCoordinator { askCount += 1; return false }
        _ = await coordinator.deliver()
        _ = await coordinator.deliver()
        #expect(askCount == 1)
        #expect(service.settingsOpenCount == 0)
    }

    @Test func acceptingTheExplanationOpensTheSettings() async {
        _ = await makeCoordinator { true }.deliver()
        #expect(service.settingsOpenCount == 1)
    }

    @Test func aPermissionGrantedLaterCountsFromTheNextPaste() async {
        let coordinator = makeCoordinator()
        _ = await coordinator.deliver()
        service.isTrusted = true
        #expect(await coordinator.deliver() == .pasted)
    }

    /// Budget of the story, with the real delay left to the keyboard.
    @Test func pastingStaysWithinItsBudget() async {
        service.isTrusted = true
        let coordinator = makeCoordinator(focusReturnDelay: Motion.focusReturnDelay)
        let elapsed = await ContinuousClock().measure {
            _ = await coordinator.deliver()
        }
        #expect(elapsed < .milliseconds(150), "\(elapsed)")
    }
}
