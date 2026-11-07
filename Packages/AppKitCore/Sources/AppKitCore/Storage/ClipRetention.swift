import Foundation

/// How long a copy stays in the history.
public enum ClipRetention: String, CaseIterable, Sendable {
    case oneDay, oneWeek, oneMonth, threeMonths, sixMonths, forever

    private static let day: TimeInterval = 24 * 60 * 60

    public var interval: TimeInterval? {
        switch self {
        case .oneDay: Self.day
        case .oneWeek: 7 * Self.day
        case .oneMonth: 30 * Self.day
        case .threeMonths: 91 * Self.day
        case .sixMonths: 182 * Self.day
        case .forever: nil
        }
    }
}
