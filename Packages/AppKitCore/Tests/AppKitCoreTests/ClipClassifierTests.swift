import AppKitCore
import Testing

struct ClipClassifierTests {
    @Test(arguments: ["public.png", "public.tiff", "public.jpeg", "public.heic", "com.compuserve.gif"])
    func recognizesEachImageFormat(type: String) {
        #expect(ClipClassifier.kind(of: [type]) == .image)
    }

    @Test func recognizesAPDF() {
        #expect(ClipClassifier.kind(of: ["com.adobe.pdf"]) == .pdf)
        #expect(ClipClassifier.kind(of: ["com.adobe.pdf", "public.tiff"]) == .pdf)
    }

    private let plain = "public.utf8-plain-text"

    @Test(arguments: ["public.rtf", "com.apple.flat-rtfd", "public.html"])
    func aRichTextIsRecognized(type: String) {
        #expect(ClipClassifier.content(ofText: "Bonjour", types: [plain, type]) == .richText("Bonjour"))
    }

    @Test(arguments: ["https://apple.com", "  https://www.apple.com/fr/?a=1\n", "http://exemple.org/page", "www.apple.com", "http://localhost:3000"])
    func anAddressAloneIsALink(text: String) {
        #expect(ClipClassifier.content(ofText: text, types: [plain]) == .link(text))
    }

    @Test func anAddressCopiedWithItsFormatsIsStillALink() {
        #expect(ClipClassifier.content(ofText: "https://apple.com", types: [plain, "public.html"]) == .link("https://apple.com"))
    }

    @Test(arguments: ["Voir https://apple.com pour la suite", "apple", "file:///tmp/a", "https://", "mailto:a@b.fr", "Bonjour."])
    func anythingElseStaysAText(text: String) {
        #expect(ClipClassifier.content(ofText: text, types: [plain]) == .text(text))
    }

    @Test func aColorInWordsIsAColorAndKeepsItsText() throws {
        guard case .color(let color) = ClipClassifier.content(ofText: "#FF5733", types: [plain]) else {
            Issue.record("Une couleur était attendue.")
            return
        }
        #expect(color.text == "#FF5733")
    }

    @Test func aNativeColorIsRecognized() {
        #expect(ClipClassifier.kind(of: [ClipClassifier.colorType]) == .color)
    }

    @Test func plainTextVariantsAreNotOtherFormats() {
        #expect(!ClipClassifier.hasOtherFormats(than: [plain, "NSStringPboardType", "org.nspasteboard.source"]))
        #expect(ClipClassifier.hasOtherFormats(than: [plain, "public.rtf"]))
    }

    @Test func aWordProcessorSelectionStaysText() {
        #expect(ClipClassifier.kind(of: ["public.utf8-plain-text", "com.adobe.pdf", "public.png"]) == .text)
    }
}
