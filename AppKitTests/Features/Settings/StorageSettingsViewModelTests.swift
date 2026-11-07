import AppKitCore
import AppKitData
import AppKitSystem
import Foundation
import Testing
@testable import AppKitMain

private struct FixedKeyService: EncryptionKeyService {
    func existingKey() throws -> Data? { Data(repeating: 1, count: ClipCipher.keyByteCount) }
    func createKey() throws -> Data { Data(repeating: 1, count: ClipCipher.keyByteCount) }
}

private struct RoomyDisk: DiskSpaceService {
    func availableBytes() -> Int64? { .max }
}

private struct NoThumbnails: ClipThumbnailService {
    func makeThumbnail(from formats: [ClipRepresentation]) async -> ClipThumbnail { ClipThumbnail(imageData: nil) }
}

@MainActor
struct StorageSettingsViewModelTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "StorageSettingsViewModelTests-\(UUID().uuidString)"))
    }

    private func makeViewModel() async throws -> (StorageSettingsViewModel, HistoryLifecycle) {
        nonisolated(unsafe) let defaults = defaults
        let lifecycle = HistoryLifecycle(
            history: ClipHistory(),
            store: try ClipStore(modelContainer: .inMemoryHistory()),
            keyService: FixedKeyService(),
            diskSpace: RoomyDisk(),
            thumbnails: NoThumbnails(),
            storagePolicy: { ClipStoragePolicy.current(in: defaults) }
        )
        await lifecycle.open()
        let tenDays = Date.now.addingTimeInterval(-10 * 86_400)
        await lifecycle.capture(ClipCapture(clip: Clip(content: .text("ancien"), source: nil, capturedAt: tenDays)))
        await lifecycle.capture(ClipCapture(clip: Clip(content: .text("récent"), source: nil, capturedAt: .now)))
        return (StorageSettingsViewModel(lifecycle: lifecycle, defaults: defaults), lifecycle)
    }

    @Test func shorteningAsksFirstAndChangesNothingYet() async throws {
        let (viewModel, lifecycle) = try await makeViewModel()

        await viewModel.request(ClipStoragePolicy(retention: .oneWeek))

        #expect(viewModel.pendingChange?.impact.ids.count == 1)
        #expect(viewModel.policy.retention == .oneMonth)
        #expect(lifecycle.history.clips.count == 2)
    }

    @Test func cancellingKeepsTheOldValue() async throws {
        let (viewModel, lifecycle) = try await makeViewModel()
        await viewModel.request(ClipStoragePolicy(retention: .oneWeek))

        viewModel.cancelPendingChange()

        #expect(viewModel.pendingChange == nil)
        #expect(viewModel.policy.retention == .oneMonth)
        #expect(lifecycle.history.clips.count == 2)
        #expect(ClipStoragePolicy.current(in: defaults).retention == .oneMonth)
    }

    @Test func confirmingDeletesAndKeepsTheNewValue() async throws {
        let (viewModel, lifecycle) = try await makeViewModel()
        await viewModel.request(ClipStoragePolicy(retention: .oneWeek))
        let change = try #require(viewModel.pendingChange)

        // The alert clears the pending change when it closes, before the action runs.
        viewModel.cancelPendingChange()
        await viewModel.confirm(change)

        #expect(lifecycle.history.clips.map(\.content) == [.text("récent")])
        #expect(ClipStoragePolicy.current(in: defaults).retention == .oneWeek)
    }

    @Test func lengtheningNeverAsks() async throws {
        let (viewModel, _) = try await makeViewModel()

        await viewModel.request(ClipStoragePolicy(retention: .sixMonths))

        #expect(viewModel.pendingChange == nil)
        #expect(viewModel.policy.retention == .sixMonths)
    }

    @Test func theUsageCountsWhatIsStored() async throws {
        let (viewModel, _) = try await makeViewModel()
        await viewModel.refresh()
        #expect(viewModel.usage.copyCount == 2)
        #expect(viewModel.usage.historyBytes > 0)
    }

    @Test func aPolicySurvivesInTheSettings() {
        ClipStoragePolicy(retention: .forever, limitInGigabytes: 5, largeThreshold: 3, largeLifetime: 60).store(in: defaults)
        let read = ClipStoragePolicy.current(in: defaults)
        #expect(read.retention == .forever)
        #expect(read.limitInGigabytes == 5)
        #expect(read.largeThreshold == 3)
        #expect(read.largeLifetime == 60)
    }
}
