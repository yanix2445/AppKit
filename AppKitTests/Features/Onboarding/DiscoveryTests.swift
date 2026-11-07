import AppKitCore
import Foundation
import Testing
@testable import AppKitMain

@MainActor
struct DiscoveryTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "DiscoveryTests-\(UUID().uuidString)"))
    }

    @Test func aTipShowsOnceEverEvenIfTheStripClosesFirst() {
        let tips = HistoryStripTips(defaults: defaults)
        tips.show(.search)
        #expect(tips.active == .search)
        tips.dismiss()
        tips.show(.search)
        #expect(tips.active == nil)
        #expect(HistoryStripTips(defaults: defaults).active == nil)
    }

    @Test func eachUseTriggersItsOwnTip() async {
        let history = ClipHistory()
        history.insert(Clip(content: .text("a"), source: nil, capturedAt: .now))
        let tips = HistoryStripTips(defaults: defaults)
        let viewModel = HistoryStripViewModel(history: history)
        viewModel.tips = tips

        viewModel.prepareForPresentation()
        #expect(tips.active == nil)
        viewModel.didAppear()
        #expect(tips.active == .paste)
        viewModel.query = "a"
        #expect(tips.active == .search)
        viewModel.togglePin(history.clips[0].id)
        #expect(tips.active == .pin)
        viewModel.didClose()
        #expect(tips.active == nil)
    }

    @Test func unpinningIsNoFirstUseOfPinning() {
        let history = ClipHistory()
        history.insert(Clip(content: .text("a"), source: nil, capturedAt: .now, isPinned: true))
        let tips = HistoryStripTips(defaults: defaults)
        let viewModel = HistoryStripViewModel(history: history)
        viewModel.tips = tips
        viewModel.togglePin(history.clips[0].id)
        #expect(tips.active == nil)
    }

    @Test func aPauseIsExplainedAtTheOpeningOfTheStrip() {
        let tips = HistoryStripTips(defaults: defaults)
        let pause = CapturePauseController(defaults: defaults)
        pause.pauseUntilResumed()
        let viewModel = HistoryStripViewModel(history: ClipHistory())
        viewModel.tips = tips
        viewModel.pause = pause
        viewModel.prepareForPresentation()
        viewModel.didAppear()
        #expect(tips.active == .pause)
    }

    @Test func theTipsFollowTheChosenShortcuts() {
        let viewModel = HistoryStripViewModel(history: ClipHistory())
        #expect(viewModel.text(of: .paste).contains("↩"))
        #expect(viewModel.text(of: .paste).contains("⇧↩"))
    }

    @Test func theDiscoveryHasItsFiveSteps() {
        #expect(OnboardingStep.allCases.count == 5)
    }
}
