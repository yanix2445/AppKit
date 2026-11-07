/// The room taken on the disk. Only the history counts against the limit.
public struct ClipStorageUsage: Equatable, Sendable {
    public var historyBytes = 0
    public var pinnedBytes = 0
    public var largeBytes = 0
    public var copyCount = 0
    public var pinnedCount = 0

    public init(items: [ClipStorageItem] = []) {
        copyCount = items.count
        for item in items {
            if item.isPinned {
                pinnedBytes += item.byteCount
                pinnedCount += 1
            } else if item.isLarge {
                largeBytes += item.byteCount
            } else {
                historyBytes += item.byteCount
            }
        }
    }
}
