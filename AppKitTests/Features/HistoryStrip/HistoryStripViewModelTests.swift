import AppKitCore
import Foundation
import SwiftUI
import Testing
@testable import AppKitMain

@MainActor
struct HistoryStripViewModelTests {
    private func clip(_ text: String) -> Clip {
        Clip(content: .text(text), source: nil, capturedAt: .now)
    }

    private func makeViewModel(_ texts: String...) -> HistoryStripViewModel {
        let history = ClipHistory()
        texts.forEach { history.insert(clip($0)) }
        return HistoryStripViewModel(history: history)
    }

    @Test func opensOnTheNewestCopy() {
        let viewModel = makeViewModel("a", "b")
        viewModel.prepareForPresentation()
        #expect(viewModel.selection?.clipID == viewModel.history.clips[0].id)
    }

    @Test func aNewCopyKeepsTheSelection() {
        let viewModel = makeViewModel("a", "b")
        viewModel.prepareForPresentation()
        let selection = viewModel.selection?.clipID
        viewModel.history.insert(clip("c"))
        viewModel.historyDidChange()
        #expect(viewModel.selection?.clipID == selection)
    }

    @Test func theFirstCopyOfAnEmptyStripIsSelectedThenKept() {
        let viewModel = makeViewModel()
        viewModel.prepareForPresentation()
        viewModel.history.insert(clip("a"))
        viewModel.historyDidChange()
        let selection = viewModel.selection?.clipID
        #expect(selection == viewModel.history.clips[0].id)
        viewModel.history.insert(clip("b"))
        viewModel.historyDidChange()
        #expect(viewModel.selection?.clipID == selection)
    }

    @Test func arrowsMoveTheSelectionWithinBounds() {
        let viewModel = makeViewModel("a", "b")
        viewModel.prepareForPresentation()
        viewModel.moveSelection(left: true)
        #expect(viewModel.selection?.clipID == viewModel.history.clips[0].id)
        viewModel.moveSelection(left: false)
        #expect(viewModel.selection?.clipID == viewModel.history.clips[1].id)
        viewModel.moveSelection(left: false)
        #expect(viewModel.selection?.clipID == viewModel.history.clips[1].id)
    }

    @Test func choosingACopyHandsItOver() {
        let history = ClipHistory()
        history.insert(clip("a"))
        history.insert(clip("b"))
        var chosen: [Clip] = []
        let viewModel = HistoryStripViewModel(history: history) { clip, _ in chosen.append(clip) }

        viewModel.choose(history.clips[1].id)

        #expect(chosen.map(\.content) == [.text("a")])
    }

    @Test func enterChoosesTheSelection() {
        let history = ClipHistory()
        history.insert(clip("a"))
        var chosen: [Clip] = []
        let viewModel = HistoryStripViewModel(history: history) { clip, _ in chosen.append(clip) }

        viewModel.chooseSelection()
        #expect(chosen.isEmpty)

        viewModel.prepareForPresentation()
        viewModel.chooseSelection()
        #expect(chosen.map(\.content) == [.text("a")])
    }

    @Test func shiftEnterAsksForPlainTextAndLeavesTheHistoryAsItIs() {
        let history = ClipHistory()
        history.insert(clip("a"))
        var styles: [ClipPasteStyle] = []
        let viewModel = HistoryStripViewModel(history: history) { _, style in styles.append(style) }
        viewModel.prepareForPresentation()
        let before = history.clips

        viewModel.chooseSelection(style: .plainText)

        #expect(styles == [.plainText])
        #expect(history.clips == before)
    }

    @Test func aSearchKeepsTheCopiesWithAllItsWords() async {
        let viewModel = makeViewModel("Décisions du bandeau", "Décisions", "autre")
        viewModel.prepareForPresentation()
        viewModel.query = "DECISIONS bandeau"
        await viewModel.searchDidFinish()
        #expect(viewModel.historyClips.map(\.content.plainText) == ["Décisions du bandeau"])
        #expect(viewModel.resultCount == 1)
    }

    @Test func aFilterCombinesWithTheSearch() async {
        let history = ClipHistory()
        history.insert(Clip(content: .link("https://bandeau.example"), source: nil, capturedAt: .now))
        history.insert(clip("bandeau"))
        history.insert(clip("autre"))
        let viewModel = HistoryStripViewModel(history: history)
        viewModel.prepareForPresentation()
        viewModel.setCategory(.link)
        #expect(viewModel.historyClips.count == 1)
        viewModel.setCategory(.text)
        viewModel.query = "bandeau"
        await viewModel.searchDidFinish()
        #expect(viewModel.historyClips.map(\.content.plainText) == ["bandeau"])
        viewModel.setCategory(.image)
        await viewModel.searchDidFinish()
        #expect(viewModel.hasNoResults)
    }

    @Test func aPinnedCopyHasTwoCardsUntilItIsLookedFor() async {
        let viewModel = makeViewModel("a", "b")
        let id = viewModel.history.clips[1].id
        _ = viewModel.history.togglePin(id)
        viewModel.prepareForPresentation()
        #expect(viewModel.pinnedClips.map(\.id) == [id])
        #expect(viewModel.historyClips.count == 2)

        viewModel.query = "a"
        await viewModel.searchDidFinish()
        #expect(viewModel.pinnedClips.map(\.id) == [id])
        #expect(viewModel.historyClips.isEmpty)
        #expect(viewModel.resultCount == 1)
    }

    @Test func escapeClearsTheSearchThenCloses() {
        let viewModel = makeViewModel("a")
        var closed = 0
        viewModel.query = "a"
        #expect(viewModel.handle(.escape, isRepeat: false) { closed += 1 })
        #expect(viewModel.query.isEmpty)
        #expect(closed == 0)
        #expect(viewModel.handle(.escape, isRepeat: false) { closed += 1 })
        #expect(closed == 1)
    }

    @Test func aDeleteKeyHeldDownErasesNothingMoreAndEditsASearch() {
        var removed: [Clip.ID] = []
        let history = ClipHistory()
        history.insert(clip("a"))
        history.insert(clip("b"))
        let viewModel = HistoryStripViewModel(history: history, actions: HistoryStripActions(remove: { removed.append($0) }))
        viewModel.prepareForPresentation()

        #expect(viewModel.handle(.delete(command: false), isRepeat: true) {})
        #expect(removed.isEmpty)

        viewModel.query = "a"
        #expect(!viewModel.handle(.delete(command: false), isRepeat: false) {})
        #expect(removed.isEmpty)
        viewModel.query = ""

        #expect(viewModel.handle(.delete(command: false), isRepeat: false) {})
        #expect(removed.count == 1)
    }

    @Test func undoLeavesTheSearchTextAloneWithoutARemoval() {
        let viewModel = makeViewModel("a")
        #expect(!viewModel.handle(.undo, isRepeat: false) {})
    }

    @Test func upAndDownAreOnlyTakenWithoutModifiers() {
        let shift = HistoryStripKey.Modifiers(shift: true)
        #expect(HistoryStripKey(keyCode: 125, character: nil, modifiers: .init()) == .vertical)
        #expect(HistoryStripKey(keyCode: 126, character: nil, modifiers: .init()) == .vertical)
        #expect(HistoryStripKey(keyCode: 125, character: nil, modifiers: shift) == nil)
        #expect(HistoryStripKey(keyCode: 126, character: nil, modifiers: shift) == nil)
    }

    @Test func theKeysDoNotDependOnTheKeyboardLayout() {
        let command = HistoryStripKey.Modifiers(command: true)
        #expect(HistoryStripKey(keyCode: 18, character: "&", modifiers: command) == .filter(0))
        #expect(HistoryStripKey(keyCode: 25, character: "ç", modifiers: command) == .filter(8))
        #expect(HistoryStripKey(keyCode: 35, character: "p", modifiers: command) == .togglePin)
        #expect(HistoryStripKey(keyCode: 123, character: nil, modifiers: .init(command: true, option: true)) == .movePinned(left: true))
        #expect(HistoryStripKey(keyCode: 0, character: "a", modifiers: .init()) == nil)
        #expect(HistoryStripKey(keyCode: 9, character: "v", modifiers: command) == nil)
    }
}
