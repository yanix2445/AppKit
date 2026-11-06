import Foundation

public struct SystemDiskSpaceService: DiskSpaceService {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func availableBytes() -> Int64? {
        try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            .volumeAvailableCapacityForImportantUsage
    }
}
