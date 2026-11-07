import AppKitCore
import Foundation
import SwiftData

/// Reads and writes sealed copies, away from the main thread. Each write is one transaction:
/// it lands whole or not at all.
@ModelActor
public actor ClipStore {
    private var cipher: ClipCipher?

    public func unlock(with cipher: ClipCipher) {
        self.cipher = cipher
    }

    /// Readable without the key, to tell an empty history from one whose key is missing.
    public func hasRecords() throws -> Bool {
        try modelContext.fetchCount(FetchDescriptor<ClipRecord>()) > 0
    }

    public func load() throws -> ClipStoreSnapshot {
        let cipher = try requireCipher()
        let descriptor = FetchDescriptor<ClipRecord>(
            sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
        )
        var clips: [Clip] = []
        var unreadableCount = 0
        let decoder = JSONDecoder()
        for record in try modelContext.fetch(descriptor) {
            do {
                let data = try cipher.open(record.sealedPayload, for: record.uid)
                let payload = try decoder.decode(ClipPayload.self, from: data)
                clips.append(
                    Clip(
                        id: record.uid,
                        content: payload.content,
                        source: payload.source,
                        capturedAt: record.capturedAt,
                        firstCapturedAt: payload.firstCapturedAt,
                        copyCount: payload.copyCount ?? 1,
                        fingerprint: payload.fingerprint,
                        isRemote: payload.isRemote ?? false
                    )
                )
            } catch {
                unreadableCount += 1
            }
        }
        return ClipStoreSnapshot(clips: clips, unreadableCount: unreadableCount)
    }

    /// - Parameters:
    ///   - formats: all the formats of an image or a PDF.
    ///   - thumbnail: its preview, sealed apart so that showing it never opens the original.
    public func insert(_ clip: Clip, formats: [ClipRepresentation] = [], thumbnail: Data? = nil) throws {
        let cipher = try requireCipher()
        let payload = try JSONEncoder().encode(ClipPayload(clip: clip))
        let searchText = Data(clip.content.searchText.utf8)
        modelContext.insert(
            ClipRecord(
                uid: clip.id,
                capturedAt: clip.capturedAt,
                byteCount: clip.content.media?.byteCount ?? payload.count,
                kind: clip.content.kindIdentifier,
                sealedPayload: try cipher.seal(payload, for: clip.id),
                sealedSearchText: try cipher.seal(searchText, for: clip.id),
                sealedFormats: formats.isEmpty ? nil : try cipher.seal(Self.encode(formats), for: clip.id),
                sealedThumbnail: try thumbnail.map { try cipher.seal($0, for: clip.id) }
            )
        )
        try saveOrRollBack()
    }

    public func formats(of id: Clip.ID) throws -> [ClipRepresentation] {
        let cipher = try requireCipher()
        guard let sealed = try record(id)?.sealedFormats else { return [] }
        return try PropertyListDecoder().decode(
            [ClipRepresentation].self,
            from: try cipher.open(sealed, for: id)
        )
    }

    public func thumbnail(of id: Clip.ID) throws -> Data? {
        let cipher = try requireCipher()
        guard let sealed = try record(id)?.sealedThumbnail else { return nil }
        return try cipher.open(sealed, for: id)
    }

    private func record(_ id: Clip.ID) throws -> ClipRecord? {
        try modelContext.fetch(FetchDescriptor<ClipRecord>(predicate: #Predicate { $0.uid == id })).first
    }

    /// A binary property list holds the bytes as they are, unlike JSON.
    private static func encode(_ formats: [ClipRepresentation]) throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        return try encoder.encode(formats)
    }

    /// Seals a newer state of a copy over the old one, keeping its formats.
    public func update(_ clip: Clip) throws {
        let cipher = try requireCipher()
        guard let record = try record(clip.id) else { return }
        record.capturedAt = clip.capturedAt
        record.sealedPayload = try cipher.seal(JSONEncoder().encode(ClipPayload(clip: clip)), for: clip.id)
        try saveOrRollBack()
    }

    public func promote(_ id: Clip.ID, at date: Date) throws {
        guard let record = try record(id) else { return }
        record.capturedAt = date
        try saveOrRollBack()
    }

    public func deleteAll() throws {
        try modelContext.delete(model: ClipRecord.self)
        try saveOrRollBack()
    }

    private func requireCipher() throws -> ClipCipher {
        guard let cipher else { throw ClipStoreError.locked }
        return cipher
    }

    private func saveOrRollBack() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
