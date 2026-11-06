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

    @Test func aWordProcessorSelectionStaysText() {
        #expect(ClipClassifier.kind(of: ["public.utf8-plain-text", "com.adobe.pdf", "public.png"]) == .text)
    }
}
