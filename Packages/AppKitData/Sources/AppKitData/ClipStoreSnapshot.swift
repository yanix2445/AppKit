import AppKitCore

/// What a load found: the copies it could open, newest first, and how many it could not.
public struct ClipStoreSnapshot: Sendable {
    public let clips: [Clip]
    public let unreadableCount: Int
}
