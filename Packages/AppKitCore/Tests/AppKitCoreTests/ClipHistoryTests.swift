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

    @Test func promotingMovesACopyToTheTopWithoutDuplicatingIt() throws {
        let history = ClipHistory()
        history.insert(clip("ancien"))
        history.insert(clip("récent"))
        let older = history.clips[1]
        let date = Date(timeIntervalSinceReferenceDate: 1_000_000_000)

        history.promote(older.id, at: date)

        #expect(history.clips.map(\.content) == [.text("ancien"), .text("récent")])
        #expect(history.clips[0].id == older.id)
        #expect(history.clips[0].capturedAt == date)
    }

    @Test func aCopyMadeAgainKeepsItsFirstDateAndCountsUp() {
        let first = Date(timeIntervalSinceReferenceDate: 100)
        let later = Date(timeIntervalSinceReferenceDate: 200)
        let source = ClipSource(name: "Notes", bundleIdentifier: nil)
        let old = Clip(content: .text("a"), source: nil, capturedAt: first)

        let merged = old.merging(newer: Clip(content: .text("a"), source: source, capturedAt: later))

        #expect(merged.id == old.id)
        #expect(merged.capturedAt == later)
        #expect(merged.firstCapturedAt == first)
        #expect(merged.copyCount == 2)
        #expect(merged.source == source)
    }

    @Test func promotingAnUnknownCopyChangesNothing() {
        let history = ClipHistory()
        history.insert(clip("seule"))
        history.promote(UUID(), at: .now)
        #expect(history.clips.count == 1)
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
