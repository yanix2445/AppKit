import Foundation

/// The durations of the interface.
enum Motion {
    static let stripSlide: TimeInterval = 0.22
    static let stripActivationGrace: Duration = .milliseconds(500)
    static let processingIndicatorDelay: Duration = .milliseconds(500)
    static let pausedRetryInterval: Duration = .seconds(30)
    static let pausedRetryTolerance: Duration = .seconds(5)
    static let storagePruneInterval: Duration = .seconds(3_600)
    static let storagePruneTolerance: Duration = .seconds(300)
    static let relativeDateRefresh: TimeInterval = 30
    static let briefMessageFade: TimeInterval = 0.15
    static let briefMessageDuration: Duration = .seconds(2)
    static let actionableMessageDuration: Duration = .seconds(6)
    static let focusReturnDelay: Duration = .milliseconds(50)
    static let focusReturnTolerance: Duration = .milliseconds(5)
}
