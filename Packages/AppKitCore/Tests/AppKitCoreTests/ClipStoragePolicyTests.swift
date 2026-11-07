import AppKitCore
import Foundation
import Testing

struct ClipStoragePolicyTests {
    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
    private let day: TimeInterval = 86_400

    private func item(daysAgo: Double = 0, bytes: Int = 10, pinned: Bool = false, large: Bool = false) -> ClipStorageItem {
        ClipStorageItem(id: UUID(), capturedAt: now.addingTimeInterval(-daysAgo * day), byteCount: bytes, isPinned: pinned, isLarge: large)
    }

    @Test func defaultsAreOneMonthAndOneGigabyte() {
        let policy = ClipStoragePolicy()
        #expect(policy.retention == .oneMonth)
        #expect(policy.limitBytes == 1_000_000_000)
        #expect(policy.effectiveLargeThreshold == 100_000_000)
    }

    @Test(arguments: [(0, 1), (1, 1), (5, 5), (10, 10), (11, 10)])
    func theLimitStaysBetweenOneAndTen(asked: Int, kept: Int) {
        #expect(ClipStoragePolicy(limitInGigabytes: asked).limitInGigabytes == kept)
    }

    @Test func oldCopiesGoButPinnedOnesStay() {
        let old = item(daysAgo: 40), recent = item(daysAgo: 1), pinned = item(daysAgo: 400, pinned: true)
        #expect(ClipStoragePolicy().itemsToDelete(from: [old, recent, pinned], now: now) == [old])
    }

    @Test func foreverKeepsEverything() {
        let policy = ClipStoragePolicy(retention: .forever)
        #expect(policy.itemsToDelete(from: [item(daysAgo: 4000)], now: now).isEmpty)
    }

    @Test func overTheLimitTheOldestGoFirst() {
        let gigabyte = ClipStoragePolicy.byteCountPerGigabyte
        let oldest = item(daysAgo: 3, bytes: gigabyte / 2)
        let middle = item(daysAgo: 2, bytes: gigabyte / 2)
        let newest = item(daysAgo: 1, bytes: gigabyte / 2)
        let policy = ClipStoragePolicy()
        #expect(policy.itemsToDelete(from: [newest, oldest, middle], now: now) == [oldest])
    }

    @Test func pinnedAndLargeCopiesDoNotCountAgainstTheLimit() {
        let gigabyte = ClipStoragePolicy.byteCountPerGigabyte
        let items = [item(bytes: gigabyte), item(bytes: 5 * gigabyte, pinned: true), item(bytes: 5 * gigabyte, large: true)]
        #expect(ClipStoragePolicy().itemsToDelete(from: items, now: now).isEmpty)
    }

    @Test func aNewerLargeCopyReplacesTheOlderOne() {
        let older = item(daysAgo: 0.5, large: true), newer = item(daysAgo: 0.1, large: true)
        #expect(ClipStoragePolicy().itemsToDelete(from: [older, newer], now: now) == [older])
    }

    @Test func aLargeCopyGoesAfterItsLifetimeUnlessPinned() {
        let expired = item(daysAgo: 2, large: true)
        #expect(ClipStoragePolicy().itemsToDelete(from: [expired], now: now) == [expired])
        let pinned = item(daysAgo: 2, pinned: true, large: true)
        #expect(ClipStoragePolicy().itemsToDelete(from: [pinned], now: now).isEmpty)
    }

    @Test func aFileByReferenceIsNeverLarge() {
        let policy = ClipStoragePolicy(largeThreshold: 1)
        #expect(!policy.isLarge(content: .files([ClipFile(path: "/tmp/a")]), storedBytes: 100))
        #expect(policy.isLarge(content: .image(ClipMedia(byteCount: 100)), storedBytes: 100))
    }

    @Test func erasingLeavesPinnedAndLargeCopies() {
        let plain = item(), pinned = item(pinned: true), large = item(large: true)
        #expect(ClipStoragePolicy.itemsToErase(from: [plain, pinned, large]) == [plain])
    }

    @Test func usageKeepsPinnedAndLargeApart() {
        let usage = ClipStorageUsage(items: [item(bytes: 1), item(bytes: 2, pinned: true), item(bytes: 4, large: true)])
        #expect(usage.historyBytes == 1)
        #expect(usage.pinnedBytes == 2)
        #expect(usage.largeBytes == 4)
        #expect(usage.copyCount == 3)
        #expect(usage.pinnedCount == 1)
    }

    @Test func theImpactAnnouncesWhatGoes() {
        let impact = ClipStorageImpact(items: [item(bytes: 3), item(bytes: 4)])
        #expect(impact.ids.count == 2)
        #expect(impact.byteCount == 7)
    }
}
