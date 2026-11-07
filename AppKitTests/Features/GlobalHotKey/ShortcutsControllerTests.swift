import AppKitCore
import AppKitSystem
import Foundation
import Testing
@testable import AppKitMain

private final class StubHotKeyService: HotKeyService {
    var taken: Set<HotKeyCombination> = []
    private(set) var registered: HotKeyCombination?
    private var onTrigger: (@MainActor () -> Void)?

    func register(_ combination: HotKeyCombination, onTrigger: @escaping @MainActor () -> Void) throws {
        unregister()
        guard !taken.contains(combination) else { throw HotKeyError.alreadyTaken }
        registered = combination
        self.onTrigger = onTrigger
    }

    func unregister() {
        registered = nil
        onTrigger = nil
    }

    func isAvailable(_ combination: HotKeyCombination) -> Bool { !taken.contains(combination) }
}

@MainActor
struct ShortcutsControllerTests {
    private let defaults: UserDefaults
    private let openHistoryService = StubHotKeyService()
    private let togglePauseService = StubHotKeyService()
    private let free = HotKeyCombination(keyCode: 40, character: "K", modifiers: [.control, .command])

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ShortcutsControllerTests-\(UUID().uuidString)"))
    }

    private func makeController() -> ShortcutsController {
        ShortcutsController(
            defaults: defaults,
            openHistory: GlobalHotKeyController(action: .openHistory, service: openHistoryService, defaults: defaults, onTrigger: {}),
            togglePause: GlobalHotKeyController(action: .togglePause, service: togglePauseService, defaults: defaults, onTrigger: {})
        )
    }

    @Test func eachGlobalShortcutHasItsOwnRegistration() {
        makeController().start()
        #expect(openHistoryService.registered == .openHistoryDefault)
        #expect(togglePauseService.registered == HotKeyAction.togglePause.defaultCombination)
    }

    @Test func aChangeAppliesAtOnceAndStaysAfterARestart() {
        let controller = makeController()
        controller.start()
        #expect(controller.set(free, for: .openHistory) == nil)
        #expect(openHistoryService.registered == free)

        let restarted = makeController()
        restarted.start()
        #expect(restarted.combination(for: .openHistory) == free)
    }

    @Test func oneTakenElsewhereChangesNothing() {
        let controller = makeController()
        controller.start()
        openHistoryService.taken = [free]
        #expect(controller.set(free, for: .openHistory) == .takenElsewhere)
        #expect(openHistoryService.registered == .openHistoryDefault)
        #expect(controller.combination(for: .openHistory) == .openHistoryDefault)
    }

    @Test func oneTakenByAnotherActionChangesNothing() {
        let controller = makeController()
        controller.start()
        let pin = HotKeyAction.togglePin.defaultCombination
        #expect(controller.set(pin, for: .delete) == .takenByAction(.togglePin))
        #expect(controller.combination(for: .delete) == HotKeyAction.delete.defaultCombination)
    }

    @Test func anErasedShortcutStaysErasedThenRestores() {
        let controller = makeController()
        controller.start()
        controller.erase(.openHistory)
        controller.erase(.delete)
        #expect(openHistoryService.registered == nil)
        #expect(controller.combination(for: .delete) == nil)

        let restarted = makeController()
        restarted.start()
        #expect(restarted.combination(for: .openHistory) == nil)
        #expect(restarted.reset(.openHistory) == nil)
        #expect(restarted.reset(.delete) == nil)
        #expect(openHistoryService.registered == .openHistoryDefault)
        #expect(restarted.combination(for: .delete) == HotKeyAction.delete.defaultCombination)
    }

    @Test func noGlobalShortcutFiresWhileOneIsTyped() {
        let controller = makeController()
        controller.start()
        controller.suspendGlobalShortcuts()
        #expect(openHistoryService.registered == nil)
        #expect(controller.combination(for: .openHistory) == .openHistoryDefault)
        controller.resumeGlobalShortcuts()
        #expect(openHistoryService.registered == .openHistoryDefault)
    }

    @Test func theStripFollowsTheChosenShortcuts() {
        var bindings = HistoryStripKey.defaultBindings
        bindings[.togglePin] = HotKeyCombination(keyCode: 14, character: "E", modifiers: [.command])
        bindings[.delete] = nil
        let command = HistoryStripKey.Modifiers(command: true)
        #expect(HistoryStripKey(keyCode: 14, character: "e", modifiers: command, bindings: bindings) == .togglePin)
        #expect(HistoryStripKey(keyCode: 35, character: "p", modifiers: command, bindings: bindings) == nil)
        #expect(HistoryStripKey(keyCode: 51, character: nil, modifiers: .init(), bindings: bindings) == nil)
    }
}
