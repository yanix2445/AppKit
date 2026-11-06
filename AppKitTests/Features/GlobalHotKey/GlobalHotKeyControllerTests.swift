import AppKitCore
import AppKitSystem
import Foundation
import Testing
@testable import AppKitMain

@MainActor
private final class FakeHotKeyService: HotKeyService {
    var taken: Set<HotKeyCombination> = []
    private(set) var current: HotKeyCombination?
    private var onTrigger: (@MainActor () -> Void)?

    func register(_ combination: HotKeyCombination, onTrigger: @escaping @MainActor () -> Void) throws {
        current = nil
        guard !taken.contains(combination) else { throw HotKeyError.alreadyTaken }
        current = combination
        self.onTrigger = onTrigger
    }

    func unregister() {
        current = nil
    }

    func isAvailable(_ combination: HotKeyCombination) -> Bool {
        !taken.contains(combination)
    }

    func press() {
        onTrigger?()
    }
}

@MainActor
struct GlobalHotKeyControllerTests {
    private let service = FakeHotKeyService()
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "GlobalHotKeyControllerTests-\(UUID().uuidString)"))
    }

    @Test func registersTheDefaultAndTriggers() {
        var triggerCount = 0
        let controller = GlobalHotKeyController(
            service: service,
            defaults: defaults,
            onTrigger: { triggerCount += 1 },
            askForFallback: { _, _ in Issue.record("Rien à demander."); return nil }
        )
        controller.start()
        #expect(controller.registered == .openHistoryDefault)

        service.press()
        #expect(triggerCount == 1)
    }

    @Test func aTakenDefaultOffersTheFallbacksWithTheirState() {
        service.taken = [.openHistoryDefault, HotKeyCombination.openHistoryFallbacks[2]]
        var offered: [HotKeyFallback] = []
        let controller = GlobalHotKeyController(
            service: service,
            defaults: defaults,
            onTrigger: {},
            askForFallback: { taken, fallbacks in
                #expect(taken == .openHistoryDefault)
                offered = fallbacks
                return fallbacks.first(where: \.isAvailable)?.combination
            }
        )
        controller.start()

        #expect(offered.map(\.isAvailable) == [true, true, false])
        #expect(controller.registered == HotKeyCombination.openHistoryFallbacks[0])
    }

    @Test func theChosenFallbackIsKeptForTheNextLaunch() {
        service.taken = [.openHistoryDefault]
        GlobalHotKeyController(
            service: service,
            defaults: defaults,
            onTrigger: {},
            askForFallback: { _, fallbacks in fallbacks[0].combination }
        ).start()

        let next = GlobalHotKeyController(
            service: service,
            defaults: defaults,
            onTrigger: {},
            askForFallback: { _, _ in Issue.record("Rien à redemander."); return nil }
        )
        next.start()
        #expect(next.registered == HotKeyCombination.openHistoryFallbacks[0])
    }

    @Test func laterLeavesNoShortcutAndStoresNothing() {
        service.taken = [.openHistoryDefault]
        let controller = GlobalHotKeyController(
            service: service,
            defaults: defaults,
            onTrigger: {},
            askForFallback: { _, _ in nil }
        )
        controller.start()

        #expect(controller.registered == nil)
        #expect(service.current == nil)
        #expect(defaults.data(forKey: GlobalHotKeyController.storageKey) == nil)
    }
}
