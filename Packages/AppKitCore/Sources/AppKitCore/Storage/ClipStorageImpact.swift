import Foundation

/// What a change would delete, to announce it exactly before doing it.
public struct ClipStorageImpact: Equatable, Sendable {
    public let ids: [UUID]
    public let byteCount: Int

    public init(items: [ClipStorageItem]) {
        ids = items.map(\.id)
        byteCount = items.reduce(0) { $0 + $1.byteCount }
    }

    public var isEmpty: Bool { ids.isEmpty }
}
