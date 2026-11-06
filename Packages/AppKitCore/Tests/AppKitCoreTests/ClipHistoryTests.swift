import AppKitCore
import Foundation
import Testing

@MainActor
struct ClipHistoryTests {
    private func clip(_ text: String) -> Clip {
        Clip(content: .text(text), source: nil, capturedAt: .now)
    }

    @Test func aNewCopyGoesFirst() {
        let history = ClipHistory()
        history.insert(clip("ancien"))
        history.insert(clip("récent"))
        #expect(history.clips.map(\.content) == [.text("récent"), .text("ancien")])
    }

    @Test func aNewHistoryStartsEmpty() {
        let history = ClipHistory()
        history.insert(clip("gardé en mémoire"))
        #expect(ClipHistory().clips.isEmpty)
    }

    @Test func insertingStaysUnderFiftyMilliseconds() {
        let history = ClipHistory()
        for index in 0..<10_000 {
            history.insert(clip("copie \(index)"))
        }
        let elapsed = ContinuousClock().measure {
            history.insert(clip("dernière"))
        }
        #expect(elapsed < .milliseconds(50))
    }
}
