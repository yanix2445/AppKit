import AppKitCore
import Foundation
import Testing
@testable import AppKitMain

@MainActor
struct ClipRestoreOutcomeTests {
    private func clip(_ content: ClipContent) -> Clip {
        Clip(content: content, source: nil, capturedAt: .now)
    }

    @Test func aTextNeedsNoFormats() {
        #expect(ClipRestoreOutcome.check(clip(.text("a")), formats: []) == .restored)
    }

    @Test func anImageWithoutItsFormatsCannotComeBack() {
        #expect(ClipRestoreOutcome.check(clip(.image(ClipMedia(byteCount: 1))), formats: []) == .unreadable)
    }

    @Test func filesThatHaveGoneCannotComeBack() {
        let gone = ClipFile(path: "/tmp/parti-\(UUID().uuidString)")
        let format = ClipRepresentation(type: ClipClassifier.fileURLType, data: Data([1]))
        #expect(ClipRestoreOutcome.check(clip(.files([gone])), formats: [format]) == .filesMissing)
    }

    @Test func oneFileLeftIsEnough() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "reste-\(UUID().uuidString)")
        try Data([1]).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let files = [ClipFile(path: "/tmp/parti-\(UUID().uuidString)"), ClipFile(path: url.path)]
        let format = ClipRepresentation(type: ClipClassifier.fileURLType, data: Data([1]))
        #expect(ClipRestoreOutcome.check(clip(.files(files)), formats: [format]) == .restored)
    }
}
