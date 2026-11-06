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
            await store(clip, formats: [], thumbnail: nil)
            return
        }
        pendingFormats[clip.id] = capture.formats
        processingTasks[clip.id] = Task {
            await process(clip.id, formats: capture.formats)
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

    private func process(_ id: Clip.ID, formats: [ClipRepresentation]) async {
        let thumbnail = await thumbnails.makeThumbnail(from: formats)
        // Read again: the copy may have moved or gone in the meantime.
        guard let clip = history.clip(withID: id), var media = clip.content.media else { return }
        media.pixelWidth = thumbnail.pixelWidth
        media.pixelHeight = thumbnail.pixelHeight
        media.pageCount = thumbnail.pageCount
        media.hasThumbnail = thumbnail.imageData != nil
        media.isProcessing = false
        let processed = Clip(
            id: clip.id,
            content: clip.content.replacingMedia(with: media),
            source: clip.source,
            capturedAt: clip.capturedAt
        )
        await store(processed, formats: formats, thumbnail: thumbnail.imageData)
        history.update(processed)
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
