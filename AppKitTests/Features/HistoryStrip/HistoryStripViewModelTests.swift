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
        #expect(viewModel.selectedClipID == viewModel.history.clips[0].id)
    }

    @Test func aNewCopyKeepsTheSelection() {
        let viewModel = makeViewModel("a", "b")
        viewModel.prepareForPresentation()
        let selection = viewModel.selectedClipID
        viewModel.history.insert(clip("c"))
        viewModel.historyDidChange()
        #expect(viewModel.selectedClipID == selection)
    }

    @Test func theFirstCopyOfAnEmptyStripIsSelectedThenKept() {
        let viewModel = makeViewModel()
        viewModel.prepareForPresentation()
        viewModel.history.insert(clip("a"))
        viewModel.historyDidChange()
        let selection = viewModel.selectedClipID
        #expect(selection == viewModel.history.clips[0].id)
        viewModel.history.insert(clip("b"))
        viewModel.historyDidChange()
        #expect(viewModel.selectedClipID == selection)
    }

    @Test func arrowsMoveTheSelectionWithinBounds() {
        let viewModel = makeViewModel("a", "b")
        viewModel.prepareForPresentation()
        viewModel.moveSelection(.left)
        #expect(viewModel.selectedClipID == viewModel.history.clips[0].id)
        viewModel.moveSelection(.right)
        #expect(viewModel.selectedClipID == viewModel.history.clips[1].id)
        viewModel.moveSelection(.right)
        #expect(viewModel.selectedClipID == viewModel.history.clips[1].id)
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
}
