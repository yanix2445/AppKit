import Foundation

/// What the store can tell about a copy without opening it.
public struct ClipStorageItem: Equatable, Sendable {
    public let id: UUID
    public let capturedAt: Date
    public let byteCount: Int
    public let isPinned: Bool
    public let isLarge: Bool

    public init(id: UUID, capturedAt: Date, byteCount: Int, isPinned: Bool = false, isLarge: Bool = false) {
        self.id = id
        self.capturedAt = capturedAt
        self.byteCount = byteCount
        self.isPinned = isPinned
        self.isLarge = isLarge
    }
}
