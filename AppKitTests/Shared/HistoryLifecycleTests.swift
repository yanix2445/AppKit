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

@MainActor
struct HistoryLifecycleTests {
    private let keyService = FakeEncryptionKeyService()
    private let disk = FakeDiskSpaceService()

    private func makeLifecycle(store: ClipStore? = nil) throws -> HistoryLifecycle {
        HistoryLifecycle(
            history: ClipHistory(),
            store: try store ?? ClipStore(modelContainer: .inMemoryHistory()),
            keyService: keyService,
            diskSpace: disk
        )
    }

    private func clip(_ text: String) -> Clip {
        Clip(content: .text(text), source: nil, capturedAt: .now)
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

        #expect(second.history.clips.map(\.id) == [saved.id])
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
}
