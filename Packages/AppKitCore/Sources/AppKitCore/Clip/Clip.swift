import Foundation

/// One entry of the history.
public struct Clip: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let content: ClipContent
    public let source: ClipSource?
    public let capturedAt: Date

    public init(
        id: UUID = UUID(),
        content: ClipContent,
        source: ClipSource?,
        capturedAt: Date
    ) {
        self.id = id
        self.content = content
        self.source = source
        self.capturedAt = capturedAt
    }
}
