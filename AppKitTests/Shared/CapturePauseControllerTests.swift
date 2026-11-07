import AppKitCore
import AppKitSystem
import Foundation
import Testing
@testable import AppKitMain

private final class FakeSoundService: SoundService {
    private(set) var played: [String] = []
    func play(named name: String) { played.append(name) }
}

@MainActor
struct CapturePauseControllerTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "CapturePauseControllerTests-\(UUID().uuidString)"))
    }

    @Test func aPauseUntilResumedSurvivesARestart() {
        CapturePauseController(defaults: defaults).pauseUntilResumed()
        let restarted = CapturePauseController(defaults: defaults)
        #expect(restarted.isPaused)
        restarted.resume()
        #expect(!CapturePauseController(defaults: defaults).isPaused)
    }

    @Test func aTimedPauseKeepsItsEndAcrossARestart() {
        CapturePauseController(defaults: defaults).pause(for: 300)
        #expect(CapturePauseController(defaults: defaults).isPaused)
    }

    @Test func aTimedPauseThatHasEndedIsOver() {
        CapturePauseController(defaults: defaults).pause(for: 300)
        let later = CapturePauseController(defaults: defaults, now: { .now.addingTimeInterval(600) })
        #expect(!later.isPaused)
    }

    @Test func aTimedPauseEndsByItself() async throws {
        let controller = CapturePauseController(defaults: defaults)
        var changes: [Bool] = []
        controller.onChange = { paused, _ in changes.append(paused) }
        controller.pause(for: 0.05)
        try await Task.sleep(for: .milliseconds(300))
        #expect(!controller.isPaused)
        #expect(changes == [true, false])
    }

    @Test func ignoringTheNextCopyEndsWithIt() {
        let controller = CapturePauseController(defaults: defaults)
        controller.ignoreNextCopy()
        #expect(controller.ignoresNextCopy)
        #expect(!controller.isPaused)
        controller.ignoredCopyWentBy()
        #expect(!controller.ignoresNextCopy)
    }

    @Test func eachCopyHasItsOwnSound() {
        let sounds = FakeSoundService()
        let feedback = CopyFeedbackController(sounds: sounds, defaults: defaults)
        feedback.copyWasKept()
        feedback.copyWasDiscarded()
        #expect(sounds.played == ["Tink", "Pop"])
    }

    @Test func aSoundCanBeChosenOrTurnedOff() {
        let sounds = FakeSoundService()
        let feedback = CopyFeedbackController(sounds: sounds, defaults: defaults)
        defaults.set("Glass", forKey: CopyFeedbackController.keptNameKey)
        defaults.set(false, forKey: CopyFeedbackController.discardedEnabledKey)
        feedback.copyWasKept()
        feedback.copyWasDiscarded()
        #expect(sounds.played == ["Glass"])
    }

    @Test func theChoicesOfTheUserMakeThePolicy() {
        defaults.set(["com.apple.Passwords"], forKey: ClipCapturePolicy.removedDefaultAppsKey)
        defaults.set(["com.apple.Notes": "Notes"], forKey: ClipCapturePolicy.addedAppsKey)
        defaults.set(["image"], forKey: ClipCapturePolicy.excludedCategoriesKey)
        let policy = ClipCapturePolicy.current(in: defaults)
        #expect(policy.allows(appIdentifier: "com.apple.Passwords"))
        #expect(!policy.allows(appIdentifier: "com.apple.Notes"))
        #expect(!policy.allows(appIdentifier: "com.bitwarden.desktop"))
        #expect(!policy.allows(category: .image))
    }
}
