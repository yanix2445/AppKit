import AppKit
import AppKitCore
import AppKitSystem
import Testing

struct SystemPasteboardServiceTests {
    /// `withUniqueName()` can hand out a released name again while other tests run in parallel.
    private func makePasteboard() -> NSPasteboard {
        NSPasteboard(name: NSPasteboard.Name("AppKitSystemTests.\(UUID().uuidString)"))
    }

    @Test func readsAPasteboardWithoutTouchingTheGeneralOne() {
        let pasteboard = makePasteboard()
        defer { pasteboard.releaseGlobally() }
        let service = SystemPasteboardService(name: pasteboard.name)
        let before = service.changeCount

        pasteboard.clearContents()
        pasteboard.setString("bonjour", forType: .string)

        #expect(service.changeCount != before)
        #expect(service.readText() == "bonjour")
    }

    @Test func formatsComeBackByteForByte() {
        let pasteboard = makePasteboard()
        defer { pasteboard.releaseGlobally() }
        let service = SystemPasteboardService(name: pasteboard.name)
        let formats = [
            ClipRepresentation(type: "public.png", data: Data((0...255).map(UInt8.init))),
            ClipRepresentation(type: "com.exemple.prive", data: Data([0, 1, 2])),
        ]

        let count = service.write(formats: formats)

        #expect(count == pasteboard.changeCount)
        let read = service.readFormats()
        #expect(read.count == 2)
        #expect(Set(read.map(\.type)) == Set(formats.map(\.type)))
        for format in formats {
            #expect(read.first { $0.type == format.type }?.data == format.data)
        }
    }

    @Test func readsAColorInSRGB() throws {
        let pasteboard = makePasteboard()
        defer { pasteboard.releaseGlobally() }
        pasteboard.clearContents()
        pasteboard.writeObjects([NSColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)])

        let color = try #require(SystemPasteboardService(name: pasteboard.name).readColor())

        #expect(color.text == "#FF0000")
    }

    @Test func readsTheTypesOfAMarkedCopy() {
        let pasteboard = makePasteboard()
        defer { pasteboard.releaseGlobally() }
        let marker = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")
        pasteboard.declareTypes([.string, marker], owner: nil)
        pasteboard.setString("motdepasse", forType: .string)
        pasteboard.setString("", forType: marker)

        let types = SystemPasteboardService(name: pasteboard.name).readTypes()

        #expect(types.contains(marker.rawValue))
    }

    @Test func writingReplacesTheContentAndReturnsTheNewCount() {
        let pasteboard = makePasteboard()
        defer { pasteboard.releaseGlobally() }
        let service = SystemPasteboardService(name: pasteboard.name)
        pasteboard.clearContents()
        pasteboard.setString("avant", forType: .string)

        let count = service.write(text: "après")

        #expect(count == pasteboard.changeCount)
        // Text alone: no format that would carry a font, a color or a link.
        let types = pasteboard.types ?? []
        #expect(types.contains(.string))
        #expect(!types.contains(.rtf) && !types.contains(.html) && !types.contains(.URL))
        #expect(service.readText() == "après")
    }
}
