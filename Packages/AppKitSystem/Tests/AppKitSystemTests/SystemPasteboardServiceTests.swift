import AppKit
import AppKitSystem
import Testing

struct SystemPasteboardServiceTests {
    @Test func readsAPasteboardWithoutTouchingTheGeneralOne() {
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        let service = SystemPasteboardService(name: pasteboard.name)
        let before = service.changeCount

        pasteboard.clearContents()
        pasteboard.setString("bonjour", forType: .string)

        #expect(service.changeCount != before)
        #expect(service.readText() == "bonjour")
    }
}
