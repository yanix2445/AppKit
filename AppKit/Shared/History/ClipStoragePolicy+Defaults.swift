import AppKitCore
import Foundation

extension ClipStoragePolicy {
    nonisolated static let retentionKey = "storageRetention"
    nonisolated static let limitKey = "storageLimitInGigabytes"
    nonisolated static let largeThresholdKey = "storageLargeThreshold"
    nonisolated static let largeLifetimeKey = "storageLargeLifetime"

    /// The policy the user chose. Read each time, as the settings can change it at any moment.
    nonisolated static func current(in defaults: UserDefaults) -> ClipStoragePolicy {
        ClipStoragePolicy(
            retention: defaults.string(forKey: retentionKey).flatMap(ClipRetention.init) ?? .oneMonth,
            limitInGigabytes: defaults.object(forKey: limitKey) as? Int ?? 1,
            largeThreshold: defaults.object(forKey: largeThresholdKey) as? Int,
            largeLifetime: defaults.object(forKey: largeLifetimeKey) as? TimeInterval ?? ClipStoragePolicy.defaultLargeLifetime
        )
    }

    nonisolated func store(in defaults: UserDefaults) {
        defaults.set(retention.rawValue, forKey: Self.retentionKey)
        defaults.set(limitInGigabytes, forKey: Self.limitKey)
        defaults.set(largeThreshold, forKey: Self.largeThresholdKey)
        defaults.set(largeLifetime, forKey: Self.largeLifetimeKey)
    }
}
