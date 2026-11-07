import AppKitCore
@testable import AppKitData
import Foundation
import SwiftData
import Testing

struct ClipStoreTests {
    private static let keyA = Data(repeating: 1, count: ClipCipher.keyByteCount)
    private static let keyB = Data(repeating: 2, count: ClipCipher.keyByteCount)

    private func makeDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "AppKitDataTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func makeStore(at url: URL, key: Data = keyA) async throws -> ClipStore {
        let store = ClipStore(modelContainer: try .history(at: url.appending(path: "History.store")))
        await store.unlock(with: try ClipCipher(keyData: key))
        return store
    }

    private func clip(_ text: String, secondsAgo: TimeInterval = 0) -> Clip {
        Clip(
            content: .text(text),
            source: ClipSource(name: "Notes", bundleIdentifier: "com.apple.Notes"),
            capturedAt: Date(timeIntervalSinceReferenceDate: 800_000_000 - secondsAgo)
        )
    }

    @Test func copiesComeBackInTheSameOrderAfterReopening() async throws {
        let directory = try makeDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let first = try await makeStore(at: directory)
        let older = clip("ancien", secondsAgo: 10)
        let newer = clip("récent")
        try await first.insert(older)
        try await first.insert(newer)

        let snapshot = try await makeStore(at: directory).load()

        #expect(snapshot.clips == [newer, older])
        #expect(snapshot.unreadableCount == 0)
    }

    @Test func noFileContainsTheCopiedTextInClear() async throws {
        let directory = try makeDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let secret = "phrase-témoin-confidentielle"
        let large = secret + String(repeating: " bourrage", count: 20_000)
        let store = try await makeStore(at: directory)
        try await store.insert(clip(secret))
        try await store.insert(clip(large, secondsAgo: 5))

        let needles = [Data(secret.utf8), Data("phrase-temoin-confidentielle".utf8), Data("Notes".utf8), Data("com.apple.Notes".utf8)]
        let enumerator = try #require(FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil))
        let files = enumerator.allObjects.compactMap { $0 as? URL }.filter { !$0.hasDirectoryPath }
        for url in files {
            let data = try Data(contentsOf: url)
            for needle in needles {
                #expect(data.range(of: needle) == nil, "\(url.lastPathComponent)")
            }
        }
        #expect(!files.isEmpty)
    }

    @Test func anotherKeyReadsNothingAndErasesNothing() async throws {
        let directory = try makeDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try await makeStore(at: directory).insert(clip("gardé"))

        let snapshot = try await makeStore(at: directory, key: Self.keyB).load()
        #expect(snapshot.clips.isEmpty)
        #expect(snapshot.unreadableCount == 1)

        #expect(try await makeStore(at: directory).load().clips.count == 1)
    }

    @Test func aLockedStoreRefusesToReadOrWrite() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await #expect(throws: ClipStoreError.locked) { try await store.insert(clip("a")) }
        await #expect(throws: ClipStoreError.locked) { try await store.load() }
    }

    @Test func aWrongSizedKeyIsRefused() {
        #expect(throws: ClipStoreError.invalidKey) { try ClipCipher(keyData: Data(count: 16)) }
    }

    @Test func promotingKeepsASingleEntryAndMovesItUp() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        let older = clip("ancien", secondsAgo: 10)
        try await store.insert(older)
        try await store.insert(clip("récent"))

        try await store.promote(older.id, at: Date(timeIntervalSinceReferenceDate: 800_000_100))

        let clips = try await store.load().clips
        #expect(clips.count == 2)
        #expect(clips[0].id == older.id)
    }

    @Test func aFailedWriteLeavesNoHalfWrittenCopy() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        let saved = clip("gardé")
        try await store.insert(saved)

        // The same identifier breaks the uniqueness rule or replaces the record, never adds a second one.
        try? await store.insert(saved)

        #expect(try await store.load().clips == [saved])
    }

    @Test func aTransactionThatNeverEndedLeavesNoTrace() async throws {
        let directory = try makeDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let saved = clip("gardé")
        try await makeStore(at: directory).insert(saved)

        // A write begun but never saved, as when the app stops before the end of a transaction.
        let container = try ModelContainer.history(at: directory.appending(path: "History.store"))
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let existing = try context.fetch(FetchDescriptor<ClipRecord>())
        try #require(existing.count == 1)
        existing[0].sealedPayload = Data("à moitié".utf8)

        let snapshot = try await makeStore(at: directory).load()
        #expect(snapshot.clips == [saved])
        #expect(snapshot.unreadableCount == 0)
    }

    @Test func anImageComesBackByteForByteWithItsThumbnail() async throws {
        let directory = try makeDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let formats = [
            ClipRepresentation(type: "public.png", data: Data((0...255).map(UInt8.init))),
            ClipRepresentation(type: "public.tiff", data: Data(repeating: 7, count: 2_000_000)),
        ]
        let media = ClipMedia(byteCount: 2_000_256, pixelWidth: 10, pixelHeight: 20, hasThumbnail: true)
        let image = Clip(content: .image(media), source: nil, capturedAt: .now)
        try await makeStore(at: directory).insert(image, formats: formats, thumbnail: Data([1, 2, 3]))

        let store = try await makeStore(at: directory)

        #expect(try await store.formats(of: image.id) == formats)
        #expect(try await store.thumbnail(of: image.id) == Data([1, 2, 3]))
        #expect(try await store.load().clips.first?.content == .image(media))
    }

    @Test func noFileContainsAnImageInClear() async throws {
        let directory = try makeDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let witness = Data("signature-de-image-témoin".utf8)
        let image = Clip(content: .image(ClipMedia(byteCount: witness.count)), source: nil, capturedAt: .now)
        try await makeStore(at: directory).insert(
            image,
            formats: [ClipRepresentation(type: "public.png", data: witness)],
            thumbnail: witness
        )

        let enumerator = try #require(FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil))
        let files = enumerator.allObjects.compactMap { $0 as? URL }.filter { !$0.hasDirectoryPath }
        for url in files {
            #expect(try Data(contentsOf: url).range(of: witness) == nil, "\(url.lastPathComponent)")
        }
    }

    @Test func aHistoryFromTheFirstVersionOpensAndKeepsItsCopies() async throws {
        let directory = try makeDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "History.store")

        // Written as the first version did, through its own schema.
        let cipher = try ClipCipher(keyData: Self.keyA)
        let old = clip("ancienne version")
        do {
            let container = try ModelContainer(
                for: Schema(versionedSchema: AppKitSchemaV1.self),
                configurations: ModelConfiguration(url: url)
            )
            let context = ModelContext(container)
            context.insert(
                AppKitSchemaV1.ClipRecord(
                    uid: old.id,
                    capturedAt: old.capturedAt,
                    byteCount: 1,
                    kind: "text",
                    sealedPayload: try cipher.seal(JSONEncoder().encode(ClipPayload(clip: old)), for: old.id),
                    sealedSearchText: try cipher.seal(Data("ancienne version".utf8), for: old.id)
                )
            )
            try context.save()
        }

        #expect(try await makeStore(at: directory).load().clips == [old])
    }

    @Test(arguments: [
        ClipContent.richText("Bonjour"),
        .link("https://apple.com"),
        .color(ClipColor(red: 1, green: 0.5, blue: 0, alpha: 0.5, text: "rgba(255, 128, 0, 0.5)")),
        .files([ClipFile(path: "/tmp/a.png"), ClipFile(path: "/tmp/b.pdf")]),
        .other,
    ])
    func eachKindComesBackAsItWas(content: ClipContent) async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        let saved = Clip(content: content, source: nil, capturedAt: .now)
        let formats = [ClipRepresentation(type: "public.rtf", data: Data([1, 2]))]

        try await store.insert(saved, formats: formats)

        #expect(try await store.load().clips.first?.content == content)
        #expect(try await store.formats(of: saved.id) == formats)
    }

    @Test func everyElementOfACopyComesBackInPlace() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        let saved = Clip(content: .other, source: nil, capturedAt: .now)
        let formats = [
            ClipRepresentation(type: "a", data: Data([1]), itemIndex: 0),
            ClipRepresentation(type: "a", data: Data([2]), itemIndex: 1),
        ]
        try await store.insert(saved, formats: formats)
        #expect(try await store.formats(of: saved.id) == formats)
    }

    @Test func updatingKeepsTheFormatsAndTheDetailsComeBack() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        let formats = [ClipRepresentation(type: "public.rtf", data: Data([1]))]
        let old = Clip(content: .richText("a"), source: nil, capturedAt: Date(timeIntervalSinceReferenceDate: 100), fingerprint: Data([7]))
        try await store.insert(old, formats: formats)

        let merged = old.merging(newer: Clip(content: .richText("a"), source: nil, capturedAt: Date(timeIntervalSinceReferenceDate: 200), isRemote: true))
        try await store.update(merged)

        let loaded = try #require(try await store.load().clips.first)
        #expect(loaded == merged)
        #expect(try await store.formats(of: old.id) == formats)
    }

    @Test func theRoomOfACopyCountsItsFormatsAndThumbnail() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        let image = Clip(content: .image(ClipMedia(byteCount: 3)), source: nil, capturedAt: .now, isLarge: true)
        try await store.insert(
            image,
            formats: [ClipRepresentation(type: "public.png", data: Data(repeating: 1, count: 5_000))],
            thumbnail: Data(repeating: 2, count: 1_000)
        )

        let item = try #require(try await store.storageItems().first)

        #expect(item.byteCount > 6_000)
        #expect(item.isLarge)
        #expect(try await store.load().clips.first?.isLarge == true)
    }

    @Test func deletingRemovesOnlyTheChosenCopies() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        let kept = clip("gardé"), gone = clip("parti", secondsAgo: 5)
        try await store.insert(kept)
        try await store.insert(gone)

        try await store.delete([gone.id])

        #expect(try await store.load().clips == [kept])
    }

    @Test func deletingEverythingEmptiesTheStore() async throws {
        let store = ClipStore(modelContainer: try .inMemoryHistory())
        await store.unlock(with: try ClipCipher(keyData: Self.keyA))
        try await store.insert(clip("a"))
        try await store.deleteAll()
        #expect(try await store.hasRecords() == false)
    }
}
