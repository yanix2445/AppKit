import AppKitCore
import AppKitData
import Foundation
import Testing

struct ClipFingerprintTests {
    private func format(_ type: String, _ bytes: [UInt8], item: Int = 0) -> ClipRepresentation {
        ClipRepresentation(type: type, data: Data(bytes), itemIndex: item)
    }

    @Test func theSameTextGivesTheSameFingerprint() {
        #expect(
            ClipFingerprint.make(content: .text("a"), formats: [])
                == ClipFingerprint.make(content: .text("a"), formats: [])
        )
        #expect(
            ClipFingerprint.make(content: .text("a"), formats: [])
                != ClipFingerprint.make(content: .text("b"), formats: [])
        )
    }

    @Test(arguments: ["org.chromium.internal.source-rfh-token", "org.chromium.source-url", "com.apple.WebKit.custom-pasteboard-data"])
    func formatsThatChangeAtEachCopyAreLeftOut(type: String) {
        let first = [format("public.html", [1]), format(type, [2])]
        let second = [format("public.html", [1]), format(type, [3])]
        #expect(
            ClipFingerprint.make(content: .richText("a"), formats: first)
                == ClipFingerprint.make(content: .richText("a"), formats: second)
        )
    }

    @Test func theSameSentenceWithAnotherStyleStaysApart() {
        #expect(
            ClipFingerprint.make(content: .richText("a"), formats: [format("public.rtf", [1])])
                != ClipFingerprint.make(content: .richText("a"), formats: [format("public.rtf", [2])])
        )
    }

    @Test func theOrderOfFormatsDoesNotMatterButTheirElementDoes() {
        let one = format("a", [1]), two = format("b", [2])
        #expect(ClipFingerprint.make(content: .other, formats: [one, two]) == ClipFingerprint.make(content: .other, formats: [two, one]))
        #expect(
            ClipFingerprint.make(content: .other, formats: [format("a", [1], item: 0)])
                != ClipFingerprint.make(content: .other, formats: [format("a", [1], item: 1)])
        )
    }
}
