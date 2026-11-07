import Foundation

/// A pause the user asked for.
public enum ClipCapturePause: Equatable, Sendable {
    case none
    case until(Date)
    case untilResumed

    public func isActive(at date: Date) -> Bool {
        switch self {
        case .none: false
        case .until(let end): date < end
        case .untilResumed: true
        }
    }
}
