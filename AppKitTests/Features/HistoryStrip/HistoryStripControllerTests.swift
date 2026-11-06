import AppKitCore
import Foundation
import Testing
@testable import AppKitMain

@MainActor
struct HistoryStripControllerTests {
    /// Budgets of the story, from the shortcut to the strip on screen, with a long history.
    @Test func opensWithinItsBudgets() {
        let history = ClipHistory()
        for index in 0..<1_000 {
            history.insert(Clip(content: .text("copie \(index)"), source: nil, capturedAt: .now))
        }
        let controller = HistoryStripController(history: history, onChoose: { _, _ in })
        let clock = ContinuousClock()

        let first = clock.measure { controller.open() }
        controller.close()
        let next = clock.measure { controller.open() }
        controller.close()

        #expect(first < .milliseconds(300), "\(first)")
        #expect(next < .milliseconds(100), "\(next)")
    }
}
