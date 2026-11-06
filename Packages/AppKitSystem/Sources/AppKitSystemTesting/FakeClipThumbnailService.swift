import AppKitCore
import AppKitSystem
import Foundation

/// Answers after a given delay, to play a slow thumbnail.
public struct FakeClipThumbnailService: ClipThumbnailService {
    private let delay: Duration
    private let thumbnail: ClipThumbnail

    public init(
        delay: Duration = .zero,
        thumbnail: ClipThumbnail = ClipThumbnail(imageData: Data([1, 2, 3]), pixelWidth: 10, pixelHeight: 20)
    ) {
        self.delay = delay
        self.thumbnail = thumbnail
    }

    public func makeThumbnail(from formats: [ClipRepresentation]) async -> ClipThumbnail {
        try? await Task.sleep(for: delay)
        return thumbnail
    }
}
