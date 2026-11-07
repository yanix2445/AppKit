import AppKitCore
import AppKitData
import AppKitSystem
import Foundation
import Observation

/// Opens the encrypted history, keeps it in step with the copies in memory, and pauses capture
/// rather than ever writing a copy in clear or by halves.
@Observable
final class HistoryLifecycle {
    /// Below this, a write might not fit and the system starts to struggle.
    static let minimumFreeBytes: Int64 = 100 * 1024 * 1024

    let history: ClipHistory
    private let store: ClipStore
    private let keyService: any EncryptionKeyService
    private let diskSpace: any DiskSpaceService
    private let thumbnails: any ClipThumbnailService
    /// The formats of copies still on their way to the disk, ready to be pasted at once.
    private var pendingFormats: [Clip.ID: [ClipRepresentation]] = [:]
    private var processingTasks: [Clip.ID: Task<Void, Never>] = [:]
    /// The entry that holds each content, to recognize a copy made again.
    private var entries: [Data: Clip.ID] = [:]

    var onStateChange: ((HistoryLifecycleState) -> Void)?

    private(set) var state: HistoryLifecycleState = .starting {
        didSet {
            if state != oldValue { onStateChange?(state) }
        }
    }

    init(
        history: ClipHistory,
        store: ClipStore,
        keyService: any EncryptionKeyService,
        diskSpace: any DiskSpaceService,
        thumbnails: any ClipThumbnailService
    ) {
        self.history = history
        self.store = store
        self.keyService = keyService
        self.diskSpace = diskSpace
        self.thumbnails = thumbnails
    }

    /// Opens the history. Called at launch, and again by Retry.
    func open() async {
        do {
            let hasRecords = try await store.hasRecords()
            guard let key = try keyService.existingKey() else {
                if hasRecords {
                    state = .keyMissing
                } else {
                    try await unlock(with: try keyService.createKey())
                    settle()
                }
                return
            }
            try await unlock(with: key)
            let snapshot = try await store.load()
            // Records that no longer open at all were sealed with another key.
            if snapshot.clips.isEmpty && snapshot.unreadableCount > 0 {
                state = .keyMissing
                return
            }
            history.replaceAll(with: snapshot.clips)
            entries = Dictionary(
                snapshot.clips.compactMap { clip in clip.fingerprint.map { ($0, clip.id) } },
                uniquingKeysWith: { first, _ in first }
            )
            startFingerprintingOlderCopies(snapshot.clips)
            settle()
        } catch EncryptionKeyError.unavailable {
            state = .keyUnavailable
        } catch {
            state = .keyUnavailable
        }
    }

    /// Tries again after a pause that may have ended.
    func resumeIfPossible() async {
        switch state {
        case .keyUnavailable:
            await open()
        case .diskFull:
            settle()
        case .starting, .ready, .keyMissing:
            break
        }
    }

    /// Shows a copy at once. An image or a PDF is then processed behind the scenes, so that a slow
    /// one never holds up the next copies.
    func capture(_ capture: ClipCapture) async {
        guard state.capturesCopies else { return }
        guard hasRoom else {
            state = .diskFull
            return
        }
        let clip = capture.clip
        history.insert(clip)
        guard !capture.formats.isEmpty else {
            await process(clip, formats: [], fingerprint: ClipFingerprint.make(content: clip.content, formats: []))
            return
        }
        pendingFormats[clip.id] = capture.formats
        let formats = capture.formats
        processingTasks[clip.id] = Task {
            // Long for a large copy: away from the main thread.
            let content = clip.content
            let fingerprint = await Task.detached { ClipFingerprint.make(content: content, formats: formats) }.value
            await process(clip, formats: formats, fingerprint: fingerprint)
            pendingFormats[clip.id] = nil
            processingTasks[clip.id] = nil
        }
    }

    /// Waits for every image and PDF being processed.
    func finishProcessing() async {
        for task in processingTasks.values {
            await task.value
        }
    }

    /// A copy made again merges with its entry, even if that only shows at the end of its processing.
    private func process(_ clip: Clip, formats: [ClipRepresentation], fingerprint: Data) async {
        if let existingID = entries[fingerprint], existingID != clip.id,
           let existing = history.clip(withID: existingID) {
            let merged = existing.merging(newer: clip)
            history.remove(clip.id)
            history.moveToTop(merged)
            try? await store.update(merged)
            return
        }
        entries[fingerprint] = clip.id

        guard let current = history.clip(withID: clip.id) else { return }
        guard var media = current.content.media else {
            let identified = current.replacing(fingerprint: fingerprint)
            history.update(identified)
            await store(identified, formats: formats, thumbnail: nil)
            return
        }
        let thumbnail = await thumbnails.makeThumbnail(from: formats)
        media.pixelWidth = thumbnail.pixelWidth
        media.pixelHeight = thumbnail.pixelHeight
        media.pageCount = thumbnail.pageCount
        media.hasThumbnail = thumbnail.imageData != nil
        media.isProcessing = false
        // Read again: the copy may have moved or gone during the thumbnail.
        guard let latest = history.clip(withID: clip.id) else { return }
        let processed = latest.replacing(content: latest.content.replacingMedia(with: media), fingerprint: fingerprint)
        await store(processed, formats: formats, thumbnail: thumbnail.imageData)
        history.update(processed)
    }

    /// Copies kept before fingerprints existed get theirs in the background, once.
    private func startFingerprintingOlderCopies(_ clips: [Clip]) {
        let older = clips.filter { $0.fingerprint == nil }
        guard !older.isEmpty else { return }
        processingTasks[UUID()] = Task {
            for clip in older {
                let formats = (try? await store.formats(of: clip.id)) ?? []
                let content = clip.content
                let fingerprint = await Task.detached { ClipFingerprint.make(content: content, formats: formats) }.value
                let identified = clip.replacing(fingerprint: fingerprint)
                if entries[fingerprint] == nil { entries[fingerprint] = clip.id }
                history.update(identified)
                try? await store.update(identified)
            }
        }
    }

    private func store(_ clip: Clip, formats: [ClipRepresentation], thumbnail: Data?) async {
        do {
            try await store.insert(clip, formats: formats, thumbnail: thumbnail)
        } catch {
            history.remove(clip.id)
            state = hasRoom && !Self.isOutOfSpace(error) ? .keyUnavailable : .diskFull
        }
    }

    /// The formats to put back on the pasteboard, available even while a copy is being processed.
    func formats(of id: Clip.ID) async -> [ClipRepresentation] {
        if let pending = pendingFormats[id] { return pending }
        return (try? await store.formats(of: id)) ?? []
    }

    func thumbnail(of id: Clip.ID) async -> Data? {
        try? await store.thumbnail(of: id)
    }

    func promote(_ clip: Clip) async {
        let date = Date.now
        history.promote(clip.id, at: date)
        try? await store.promote(clip.id, at: date)
    }

    /// Erases the history that can no longer be read, pinned copies included, and starts anew.
    func startOver() async {
        do {
            try await store.deleteAll()
            try await unlock(with: try keyService.createKey())
            history.replaceAll(with: [])
            entries.removeAll()
            settle()
        } catch {
            state = .keyUnavailable
        }
    }

    private var hasRoom: Bool {
        (diskSpace.availableBytes() ?? .max) >= Self.minimumFreeBytes
    }

    private func settle() {
        state = hasRoom ? .ready : .diskFull
    }

    private func unlock(with key: Data) async throws {
        await store.unlock(with: try ClipCipher(keyData: key))
    }

    private static func isOutOfSpace(_ error: any Error) -> Bool {
        let error = error as NSError
        let sqliteFull = 13
        if error.domain == NSCocoaErrorDomain && error.code == NSFileWriteOutOfSpaceError { return true }
        if error.domain == NSPOSIXErrorDomain && error.code == Int(ENOSPC) { return true }
        if error.domain == "NSSQLiteErrorDomain" && error.code == sqliteFull { return true }
        if let underlying = error.userInfo[NSUnderlyingErrorKey] as? any Error {
            return isOutOfSpace(underlying)
        }
        return false
    }
}
