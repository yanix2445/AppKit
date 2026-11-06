import AppKitCore
import Foundation
import Testing

struct HotKeyCombinationTests {
    @Test func theDefaultIsShiftCommandV() {
        #expect(HotKeyCombination.openHistoryDefault.displayName == "⇧⌘V")
    }

    @Test func theFallbacksComeInTheAgreedOrder() {
        #expect(HotKeyCombination.openHistoryFallbacks.map(\.displayName) == ["⌥⌘V", "⇧⌘C", "⌃⌘V"])
    }

    @Test func aCombinationSurvivesEncoding() throws {
        let combination = HotKeyCombination.openHistoryFallbacks[0]
        let data = try JSONEncoder().encode(combination)
        #expect(try JSONDecoder().decode(HotKeyCombination.self, from: data) == combination)
    }
}
