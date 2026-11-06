import AppKitCore
import Testing

struct ClipContentTests {
    @Test(arguments: [("une", 1), ("a\nb\nc", 3), ("a\n\nb", 3), ("a\n", 2)])
    func countsLines(text: String, expected: Int) {
        #expect(ClipContent.text(text).lineCount == expected)
    }
}
