import AppKitCore
import AppKitData
import AppKitSystem
import Foundation
import Synchronization
import Testing
@testable import AppKitMain

private final class FakeEncryptionKeyService: EncryptionKeyService {
    private struct State {
        var key: Data?
        var isUnavailable = false
    }

    private let state = Mutex(State())

    init(key: Data? = nil) {
        state.withLock { $0.key = key }
    }

    func setUnavailable(_ value: Bool) {
        state.withLock { $0.isUnavailable = value }
    }

    func setKey(_ key: Data?) {
        state.withLock { $0.key = key }
    }

    func existingKey() throws -> Data? {
        try state.withLock {
            if $0.isUnavailable { throw EncryptionKeyError.unavailable }
            return $0.key
        }
    }

    func createKey() throws -> Data {
        try state.withLock {
            if $0.isUnavailable { throw EncryptionKeyError.unavailable }
            let key = Data((0..<ClipCipher.keyByteCount).map { _ in UInt8.random(in: .min ... .max) })
            $0.key = key
            return key
        }
    }
}

private final class FakeDiskSpaceService: DiskSpaceService {
    private let bytes = Mutex<Int64?>(.max)

    func set(_ value: Int64?) {
        bytes.withLock { $0 = value }
    }

    func availableBytes() -> Int64? {
        bytes.withLock { $0 }
    }
}

private struct StubThumbnailService: ClipThumbnailService {
    var delay: Duration = .zero

    func makeThumbnail(from formats: [ClipRepresentation]) async -> ClipThumbnail {
        try? await Task.sleep(for: delay)
        return ClipThumbnail(imageData: Data([1]), pixelWidth: 10, pixelHeight: 20)
    }
}

@MainActor
struct HistoryLifecycleTests {
    private let keyService = FakeEncryptionKeyService()
    private let disk = FakeDiskSpaceService()
    private var thumbnails: any ClipThumbnailService = StubThumbnailService()

    private func makeLifecycle(store: ClipStore? = nil) throws -> HistoryLifecycle {
        HistoryLifecycle(
            history: ClipHistory(),
            store: try store ?? ClipStore(modelContainer: .inMemoryHistory()),
            keyService: keyService,
            diskSpace: disk,
            thumbnails: thumbnails
        )
    }

    private func clip(_ text: String) -> ClipCapture {
        ClipCapture(clip: Clip(content: .text(text), source: nil, capturedAt: .now))
    }

    private func image(formats: [ClipRepresentation]) -> ClipCapture {
        ClipCapture(
            clip: Clip(content: .image(ClipMedia(byteCount: 3, isProcessing: true)), source: nil, capturedAt: .now),
            formats: formats
        )
    }

    @Test func aFirstLaunchCreatesAKeyAndCaptures() async throws {
        let lifecycle = try makeLifecycle()
        await lifecycle.open()
        #expect(lifecycle.state == .ready)
        #expect(try keyService.existingKey() != nil)
    }

    @Test func copiesComeBackWithTheKey() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let first = try makeLifecycle(store: store)
        await first.open()
        let saved = clip("gardé")
        await first.capture(saved)

        let second = try makeLifecycle(store: store)
        await second.open()

        #expect(second.history.clips.map(\.id) == [saved.clip.id])
    }

    @Test func aMissingKeyErasesNothingAndCreatesNoKey() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let first = try makeLifecycle(store: store)
        await first.open()
        await first.capture(clip("gardé"))
        keyService.setKey(nil)

        let second = try makeLifecycle(store: store)
        await second.open()

        #expect(second.state == .keyMissing)
        #expect(try keyService.existingKey() == nil)
        #expect(try await store.hasRecords())
        #expect(second.history.clips.isEmpty)
    }

    @Test func anotherKeyCountsAsMissingAndErasesNothing() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let first = try makeLifecycle(store: store)
        await first.open()
        await first.capture(clip("gardé"))
        keyService.setKey(Data(repeating: 7, count: ClipCipher.keyByteCount))

        let second = try makeLifecycle(store: store)
        await second.open()

        #expect(second.state == .keyMissing)
        #expect(try await store.hasRecords())
    }

    @Test func retryFindsAKeyThatCameBack() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let first = try makeLifecycle(store: store)
        await first.open()
        await first.capture(clip("gardé"))
        let key = try keyService.existingKey()
        keyService.setKey(nil)

        let second = try makeLifecycle(store: store)
        await second.open()
        keyService.setKey(key)
        await second.open()

        #expect(second.state == .ready)
        #expect(second.history.clips.count == 1)
    }

    @Test func startingOverErasesEverythingAndCapturesAgain() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let first = try makeLifecycle(store: store)
        await first.open()
        await first.capture(clip("gardé"))
        keyService.setKey(nil)

        let second = try makeLifecycle(store: store)
        await second.open()
        await second.startOver()

        #expect(second.state == .ready)
        #expect(try await store.hasRecords() == false)
        #expect(try keyService.existingKey() != nil)
    }

    @Test func anUnavailableKeyPausesCaptureThenResumes() async throws {
        keyService.setUnavailable(true)
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let lifecycle = try makeLifecycle(store: store)
        await lifecycle.open()
        #expect(lifecycle.state == .keyUnavailable)

        await lifecycle.capture(clip("pendant la pause"))
        #expect(lifecycle.history.clips.isEmpty)
        #expect(try await store.hasRecords() == false)

        keyService.setUnavailable(false)
        await lifecycle.resumeIfPossible()
        #expect(lifecycle.state == .ready)
    }

    @Test func aFullDiskPausesCaptureThenResumesByItself() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let lifecycle = try makeLifecycle(store: store)
        await lifecycle.open()

        disk.set(HistoryLifecycle.minimumFreeBytes - 1)
        await lifecycle.capture(clip("sans place"))
        #expect(lifecycle.state == .diskFull)
        #expect(lifecycle.history.clips.isEmpty)
        #expect(try await store.hasRecords() == false)

        await lifecycle.resumeIfPossible()
        #expect(lifecycle.state == .diskFull)

        disk.set(HistoryLifecycle.minimumFreeBytes)
        await lifecycle.resumeIfPossible()
        #expect(lifecycle.state == .ready)
        await lifecycle.capture(clip("avec place"))
        #expect(lifecycle.history.clips.count == 1)
    }

    @Test func eachStateChangeIsReported() async throws {
        let lifecycle = try makeLifecycle()
        var states: [HistoryLifecycleState] = []
        lifecycle.onStateChange = { states.append($0) }
        await lifecycle.open()
        #expect(states == [.ready])
    }

    @Test mutating func aSlowImageShowsAtOnceAndPastesWhileProcessing() async throws {
        thumbnails = StubThumbnailService(delay: .seconds(1))
        let lifecycle = try makeLifecycle()
        await lifecycle.open()
        let formats = [ClipRepresentation(type: "public.png", data: Data([1, 2, 3]))]
        let capture = image(formats: formats)

        let elapsed = await ContinuousClock().measure {
            await lifecycle.capture(capture)
        }

        #expect(elapsed < .milliseconds(50), "\(elapsed)")
        #expect(lifecycle.history.clips.first?.content.media?.isProcessing == true)
        #expect(await lifecycle.formats(of: capture.clip.id) == formats)
    }

    @Test func aProcessedImageGetsItsDetailsAndStaysOnDisk() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let lifecycle = try makeLifecycle(store: store)
        await lifecycle.open()
        let formats = [ClipRepresentation(type: "public.png", data: Data([1, 2, 3]))]
        let capture = image(formats: formats)

        await lifecycle.capture(capture)
        await lifecycle.finishProcessing()

        let media = try #require(lifecycle.history.clips.first?.content.media)
        #expect(!media.isProcessing)
        #expect(media.hasThumbnail)
        #expect(media.pixelWidth == 10)
        #expect(await lifecycle.formats(of: capture.clip.id) == formats)
        #expect(await lifecycle.thumbnail(of: capture.clip.id) == Data([1]))
    }

    @Test func aTextCopiedAgainKeepsOneEntryAtTheTop() async throws {
        let lifecycle = try makeLifecycle()
        await lifecycle.open()
        let first = clip("répété")
        await lifecycle.capture(first)
        await lifecycle.capture(clip("autre"))
        await lifecycle.capture(clip("répété"))

        #expect(lifecycle.history.clips.map(\.content) == [.text("répété"), .text("autre")])
        #expect(lifecycle.history.clips[0].id == first.clip.id)
        #expect(lifecycle.history.clips[0].copyCount == 2)
        #expect(lifecycle.history.clips[0].firstCapturedAt == first.clip.capturedAt)
    }

    @Test func aDuplicateFoundAtTheEndOfProcessingMerges() async throws {
        let lifecycle = try makeLifecycle()
        await lifecycle.open()
        let formats = [ClipRepresentation(type: "public.png", data: Data([1, 2, 3]))]
        let first = image(formats: formats)
        await lifecycle.capture(first)
        await lifecycle.finishProcessing()

        let second = image(formats: formats)
        await lifecycle.capture(second)
        #expect(lifecycle.history.clips.count == 2)
        await lifecycle.finishProcessing()

        #expect(lifecycle.history.clips.map(\.id) == [first.clip.id])
        #expect(lifecycle.history.clips[0].copyCount == 2)
    }

    @Test func duplicatesAreStillRecognizedAfterARelaunch() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let first = try makeLifecycle(store: store)
        await first.open()
        await first.capture(clip("répété"))

        let second = try makeLifecycle(store: store)
        await second.open()
        await second.capture(clip("répété"))

        #expect(second.history.clips.count == 1)
        #expect(second.history.clips[0].copyCount == 2)
    }

    @Test func theSameSentenceWithAnotherStyleStaysApart() async throws {
        let lifecycle = try makeLifecycle()
        await lifecycle.open()
        for byte: UInt8 in [1, 2] {
            await lifecycle.capture(ClipCapture(
                clip: Clip(content: .richText("Bonjour"), source: nil, capturedAt: .now),
                formats: [ClipRepresentation(type: "public.rtf", data: Data([byte]))]
            ))
            await lifecycle.finishProcessing()
        }
        #expect(lifecycle.history.clips.count == 2)
    }

    /// The budget of the story, from login to ready to capture, with a long history.
    @Test func openingALongHistoryIsReadyWithinASecond() async throws {
        let store = try ClipStore(modelContainer: .inMemoryHistory())
        let first = try makeLifecycle(store: store)
        await first.open()
        for index in 0..<1_000 {
            await first.capture(clip("copie \(index)"))
        }

        let second = try makeLifecycle(store: store)
        let elapsed = await ContinuousClock().measure {
            await second.open()
        }

        #expect(second.state == .ready)
        #expect(second.history.clips.count == 1_000)
        #expect(elapsed < .seconds(1), "\(elapsed)")
    }
}
