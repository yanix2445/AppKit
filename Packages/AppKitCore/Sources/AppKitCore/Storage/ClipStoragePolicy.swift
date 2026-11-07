import Foundation

/// The rules that keep the history within what the user chose. A pinned copy is never touched.
public struct ClipStoragePolicy: Equatable, Sendable {
    public static let byteCountPerGigabyte = 1_000_000_000
    public static let limitRange = 1...10
    public static let defaultLargeLifetime: TimeInterval = 24 * 60 * 60

    public var retention: ClipRetention
    public var limitInGigabytes: Int
    /// `nil` means a tenth of the limit.
    public var largeThreshold: Int?
    public var largeLifetime: TimeInterval

    public init(
        retention: ClipRetention = .oneMonth,
        limitInGigabytes: Int = 1,
        largeThreshold: Int? = nil,
        largeLifetime: TimeInterval = ClipStoragePolicy.defaultLargeLifetime
    ) {
        self.retention = retention
        self.limitInGigabytes = min(max(limitInGigabytes, Self.limitRange.lowerBound), Self.limitRange.upperBound)
        self.largeThreshold = largeThreshold
        self.largeLifetime = largeLifetime
    }

    public var limitBytes: Int { limitInGigabytes * Self.byteCountPerGigabyte }
    public var effectiveLargeThreshold: Int { largeThreshold ?? limitBytes / 10 }

    /// A file kept by reference is never large, whatever its size: what counts is what AppKit stores.
    public func isLarge(content: ClipContent, storedBytes: Int) -> Bool {
        if case .files = content { return false }
        return storedBytes > effectiveLargeThreshold
    }

    /// What should go now: expired copies, then the oldest ones over the limit, then large copies
    /// past their lifetime or replaced by a newer one.
    public func itemsToDelete(from items: [ClipStorageItem], now: Date) -> [ClipStorageItem] {
        var doomed = expiredHistory(in: items, now: now)
        let doomedIDs = Set(doomed.map(\.id))
        let history = items
            .filter { !$0.isPinned && !$0.isLarge && !doomedIDs.contains($0.id) }
            .sorted { $0.capturedAt < $1.capturedAt }
        var excess = history.reduce(0) { $0 + $1.byteCount } - limitBytes
        for item in history where excess > 0 {
            doomed.append(item)
            excess -= item.byteCount
        }
        let large = items
            .filter { !$0.isPinned && $0.isLarge }
            .sorted { $0.capturedAt > $1.capturedAt }
        for (index, item) in large.enumerated() {
            if index > 0 || now.timeIntervalSince(item.capturedAt) > largeLifetime {
                doomed.append(item)
            }
        }
        return doomed
    }

    private func expiredHistory(in items: [ClipStorageItem], now: Date) -> [ClipStorageItem] {
        guard let interval = retention.interval else { return [] }
        return items.filter { !$0.isPinned && !$0.isLarge && now.timeIntervalSince($0.capturedAt) > interval }
    }

    /// What "erase everything" deletes: neither the pinned copies nor the large ones.
    public static func itemsToErase(from items: [ClipStorageItem]) -> [ClipStorageItem] {
        items.filter { !$0.isPinned && !$0.isLarge }
    }
}
