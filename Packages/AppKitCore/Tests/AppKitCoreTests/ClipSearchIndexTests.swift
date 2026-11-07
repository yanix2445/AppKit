import Foundation
import Testing
@testable import AppKitCore

struct ClipSearchIndexTests {
    private func clip(_ content: ClipContent) -> Clip {
        Clip(content: content, source: nil, capturedAt: .now)
    }

    @Test func caseAndAccentsDoNotMatter() {
        let found = clip(.text("Décisions du Bandeau"))
        let index = ClipSearchIndex([found, clip(.text("autre"))])
        #expect(index.matches(for: "DECISIONS") == [found.id])
        #expect(index.matches(for: "décisions") == [found.id])
    }

    @Test func aResultHoldsEveryWordEachOnItsOwn() {
        let both = clip(.text("bandeau et décisions"))
        let one = clip(.text("bandeau"))
        let index = ClipSearchIndex([both, one])
        #expect(index.matches(for: "decisions bandeau") == [both.id])
        #expect(index.matches(for: "bandeau") == [both.id, one.id])
        #expect(index.matches(for: "bandeau absent").isEmpty)
    }

    @Test func aWordFoundTwiceDoesNotCountAsTwo() {
        let index = ClipSearchIndex([clip(.text("bandeau bandeau"))])
        #expect(index.matches(for: "bandeau absent").isEmpty)
    }

    @Test func linksFileNamesAndColorsAreSearched() {
        let link = clip(.link("https://apple.com"))
        let files = clip(.files([ClipFile(path: "/tmp/Rapport annuel.pdf")]))
        let color = clip(.color(ClipColor(red: 0, green: 0, blue: 0, text: "#3B82F6")))
        let index = ClipSearchIndex([link, files, color])
        #expect(index.matches(for: "apple") == [link.id])
        #expect(index.matches(for: "rapport") == [files.id])
        #expect(index.matches(for: "3b82") == [color.id])
    }

    @Test func aWordDoesNotRunFromOneCopyIntoTheNext() {
        let index = ClipSearchIndex([clip(.text("ban")), clip(.text("deau"))])
        #expect(index.matches(for: "bandeau").isEmpty)
    }

    @Test func emptySearchAndEmptyIndex() {
        let only = clip(.text("a"))
        #expect(ClipSearchIndex([only]).matches(for: "  ") == [only.id])
        #expect(ClipSearchIndex([]).matches(for: "a").isEmpty)
    }
}

@MainActor
struct ClipHistoryOrganizingTests {
    private func makeHistory(_ count: Int) -> ClipHistory {
        let history = ClipHistory()
        for number in 0..<count {
            history.insert(Clip(content: .text("\(number)"), source: nil, capturedAt: Date(timeIntervalSinceReferenceDate: Double(number))))
        }
        return history
    }

    @Test func pinningAddsAtTheEndAndUnpinningTakesOut() {
        let history = makeHistory(3)
        let ids = history.clips.map(\.id)
        _ = history.togglePin(ids[2])
        _ = history.togglePin(ids[0])
        #expect(history.pinned.map(\.id) == [ids[2], ids[0]])
        _ = history.togglePin(ids[2])
        #expect(history.pinned.map(\.id) == [ids[0]])
    }

    @Test func aPinnedCopyMovesAndOnlyThoseThatChangeAreReturned() {
        let history = makeHistory(3)
        let ids = history.clips.map(\.id)
        ids.forEach { _ = history.togglePin($0) }
        let changed = history.movePinned(ids[2], to: 0)
        #expect(history.pinned.map(\.id) == [ids[2], ids[0], ids[1]])
        #expect(changed.count == 3)
        #expect(history.movePinned(ids[2], to: -5).isEmpty)
        #expect(history.movePinned(UUID(), to: 0).isEmpty)
    }

    @Test func aCopyMadeAgainStaysPinnedAtItsPlaceInTheSection() {
        let history = makeHistory(2)
        let ids = history.clips.map(\.id)
        ids.forEach { _ = history.togglePin($0) }
        let newer = Clip(content: .text("0"), source: nil, capturedAt: .now)
        let merged = history.clips[1].merging(newer: newer)
        history.moveToTop(merged)
        #expect(merged.isPinned)
        #expect(history.pinned.map(\.id) == ids)
        #expect(history.clips[0].id == ids[1])
    }

    @Test func aRemovedCopyComesBackAtItsPlaceByDate() throws {
        let history = makeHistory(3)
        let middle = history.clips[1]
        history.remove(middle.id)
        history.restore(middle)
        #expect(history.clips[1].id == middle.id)
    }
}
