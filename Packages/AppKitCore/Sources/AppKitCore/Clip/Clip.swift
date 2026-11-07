import Foundation

/// One entry of the history.
public struct Clip: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let content: ClipContent
    public let source: ClipSource?
    /// The last time this copy was made.
    public let capturedAt: Date
    /// The first time this copy was made, kept when it is copied again.
    public let firstCapturedAt: Date
    public let copyCount: Int
    /// Identifies the content, to recognize the same copy made again.
    public let fingerprint: Data?
    /// Came from another device through Universal Clipboard.
    public let isRemote: Bool

    public init(
        id: UUID = UUID(),
        content: ClipContent,
        source: ClipSource?,
        capturedAt: Date,
        firstCapturedAt: Date? = nil,
        copyCount: Int = 1,
        fingerprint: Data? = nil,
        isRemote: Bool = false
    ) {
        self.id = id
        self.content = content
        self.source = source
        self.capturedAt = capturedAt
        self.firstCapturedAt = firstCapturedAt ?? capturedAt
        self.copyCount = copyCount
        self.fingerprint = fingerprint
        self.isRemote = isRemote
    }

    public func replacing(content: ClipContent? = nil, capturedAt: Date? = nil, fingerprint: Data? = nil) -> Clip {
        Clip(
            id: id,
            content: content ?? self.content,
            source: source,
            capturedAt: capturedAt ?? self.capturedAt,
            firstCapturedAt: firstCapturedAt,
            copyCount: copyCount,
            fingerprint: fingerprint ?? self.fingerprint,
            isRemote: isRemote
        )
    }

    /// This copy made again by `newer`: same entry, with the newer date and origin.
    public func merging(newer: Clip) -> Clip {
        Clip(
            id: id,
            content: content,
            source: newer.source,
            capturedAt: newer.capturedAt,
            firstCapturedAt: firstCapturedAt,
            copyCount: copyCount + 1,
            fingerprint: fingerprint,
            isRemote: newer.isRemote
        )
    }
}
