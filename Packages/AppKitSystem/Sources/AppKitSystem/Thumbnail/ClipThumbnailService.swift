import AppKitCore

/// Makes the preview of a copy, however long that takes.
public protocol ClipThumbnailService: Sendable {
    func makeThumbnail(from formats: [ClipRepresentation]) async -> ClipThumbnail
}
