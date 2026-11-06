import AppKitCore
import Testing

struct ClipContentTests {
    @Test(arguments: [("une", 1), ("a\nb\nc", 3), ("a\n\nb", 3), ("a\n", 2)])
    func countsLines(text: String, expected: Int) {
        #expect(ClipContent.text(text).lineCount == expected)
    }

    @Test func theSearchTextIgnoresCaseAndAccents() {
        #expect(ClipContent.text("Réunion FACTURÉE").searchText == "reunion facturee")
    }

    @Test func theSearchTextIsCutToTheLimit() {
        let text = String(repeating: "a", count: ClipContent.searchTextLimit + 10)
        #expect(ClipContent.text(text).searchText.count == ClipContent.searchTextLimit)
    }
}
