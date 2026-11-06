import AppKitCore
import AppKitSystem
import AppKitSystemTesting
import Testing

struct ClipboardMonitorTests {
    private let source = ClipSource(name: "Notes", bundleIdentifier: "com.apple.Notes")

    private func makeMonitor(
        _ pasteboard: FakePasteboardService,
        policy: ClipboardPollingPolicy = .standard
    ) -> ClipboardMonitor {
        ClipboardMonitor(
            pasteboard: pasteboard,
            frontmostApp: FakeFrontmostAppService(source: source),
            policy: policy
        )
    }

    @Test func ignoresWhatWasCopiedBeforeLaunch() async {
        let pasteboard = FakePasteboardService()
        pasteboard.copy(text: "avant")
        let monitor = makeMonitor(pasteboard)
        #expect(await monitor.poll() == nil)
    }

    @Test func capturesANewTextWithItsSource() async throws {
        let pasteboard = FakePasteboardService()
        let monitor = makeMonitor(pasteboard)
        pasteboard.copy(text: "bonjour")
        let clip = try #require(await monitor.poll())
        #expect(clip.content == .text("bonjour"))
        #expect(clip.source == source)
    }

    @Test func capturesACopyOnlyOnce() async {
        let pasteboard = FakePasteboardService()
        let monitor = makeMonitor(pasteboard)
        pasteboard.copy(text: "bonjour")
        _ = await monitor.poll()
        #expect(await monitor.poll() == nil)
    }

    @Test(arguments: [nil, ""] as [String?])
    func ignoresACopyWithoutText(text: String?) async {
        let pasteboard = FakePasteboardService()
        let monitor = makeMonitor(pasteboard)
        pasteboard.copy(text: text)
        #expect(await monitor.poll() == nil)
    }

    @Test func restoringPutsTheExactTextBackWithoutANewCapture() async {
        let pasteboard = FakePasteboardService()
        let monitor = makeMonitor(pasteboard)
        let text = "  deux lignes\n et des espaces  "

        await monitor.restore(Clip(content: .text(text), source: source, capturedAt: .now))

        #expect(pasteboard.readText() == text)
        #expect(await monitor.poll() == nil)
    }

    @Test func aCopyAfterARestoreIsStillCaptured() async {
        let pasteboard = FakePasteboardService()
        let monitor = makeMonitor(pasteboard)
        await monitor.restore(Clip(content: .text("remis"), source: source, capturedAt: .now))
        pasteboard.copy(text: "nouveau")
        #expect(await monitor.poll()?.content == .text("nouveau"))
    }

    @Test func thePollingStreamDeliversACopy() async throws {
        let pasteboard = FakePasteboardService()
        let monitor = makeMonitor(
            pasteboard,
            policy: ClipboardPollingPolicy(interval: .milliseconds(5), tolerance: .milliseconds(1))
        )
        var iterator = await monitor.clips().makeAsyncIterator()
        pasteboard.copy(text: "bonjour")
        let clip = try #require(await iterator.next())
        #expect(clip.content == .text("bonjour"))
    }
}
