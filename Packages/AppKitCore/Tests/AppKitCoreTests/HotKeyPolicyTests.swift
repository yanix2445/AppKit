import Testing
@testable import AppKitCore

struct HotKeyPolicyTests {
    private let defaults = Dictionary(uniqueKeysWithValues: HotKeyAction.allCases.map { ($0, $0.defaultCombination) })

    private func combination(_ character: String, keyCode: UInt32 = 0, _ modifiers: HotKeyModifiers) -> HotKeyCombination {
        HotKeyCombination(keyCode: keyCode, character: character, modifiers: modifiers)
    }

    @Test func aGlobalShortcutNeedsCommandControlOrOption() {
        #expect(HotKeyPolicy.problem(with: combination("K", [.shift]), for: .openHistory, current: defaults) == .needsGlobalModifier)
        #expect(HotKeyPolicy.problem(with: combination("K", []), for: .togglePause, current: defaults) == .needsGlobalModifier)
        #expect(HotKeyPolicy.problem(with: combination("K", [.control]), for: .openHistory, current: defaults) == nil)
        #expect(HotKeyPolicy.problem(with: combination("K", [.option]), for: .togglePause, current: defaults) == nil)
    }

    @Test func inTheStripAPlainKeyIsTextForTheSearch() {
        #expect(HotKeyPolicy.problem(with: combination("K", []), for: .togglePin, current: defaults) == .needsModifierOrSpecialKey)
        #expect(HotKeyPolicy.problem(with: combination("K", [.shift]), for: .togglePin, current: defaults) == .needsModifierOrSpecialKey)
        #expect(HotKeyPolicy.problem(with: combination("␣", keyCode: 49, []), for: .togglePin, current: defaults) == .needsModifierOrSpecialKey)
        #expect(HotKeyPolicy.problem(with: combination("K", [.command]), for: .togglePin, current: defaults) == nil)
        #expect(HotKeyPolicy.problem(with: combination("⌦", keyCode: 117, []), for: .delete, current: defaults) == nil)
    }

    @Test func theDefaultsAreAllAllowedForThemselves() {
        for action in HotKeyAction.allCases {
            #expect(HotKeyPolicy.problem(with: action.defaultCombination, for: action, current: defaults) == nil, "\(action)")
        }
    }

    @Test func whatMacOSReservesIsRefused() {
        for letter in ["Q", "W", "H", "M"] {
            #expect(HotKeyPolicy.problem(with: combination(letter, [.command]), for: .togglePin, current: defaults) == .reservedByMacOS)
        }
        #expect(HotKeyPolicy.problem(with: combination("⇥", keyCode: 48, [.command]), for: .openHistory, current: defaults) == .reservedByMacOS)
    }

    @Test func whatTheStripUsesForItselfIsRefused() {
        #expect(HotKeyPolicy.problem(with: combination("Z", [.command]), for: .togglePin, current: defaults) == .reservedByStrip)
        #expect(HotKeyPolicy.problem(with: combination("V", [.command]), for: .togglePin, current: defaults) == .reservedByStrip)
        #expect(HotKeyPolicy.problem(with: combination("←", keyCode: 123, []), for: .togglePin, current: defaults) == .reservedByStrip)
        #expect(HotKeyPolicy.problem(with: combination("1", keyCode: 18, [.command]), for: .togglePin, current: defaults) == .reservedByStrip)
    }

    @Test func anotherActionHoldingItIsNamed() {
        let taken = HotKeyAction.movePinnedRight.defaultCombination
        #expect(HotKeyPolicy.problem(with: taken, for: .togglePin, current: defaults) == .takenByAction(.movePinnedRight))
    }
}
