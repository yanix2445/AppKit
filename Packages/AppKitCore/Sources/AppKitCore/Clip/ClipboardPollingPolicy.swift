/// How often the pasteboard counter is read. The tolerance lets macOS group wake-ups.
public struct ClipboardPollingPolicy: Equatable, Sendable {
    public let interval: Duration
    public let tolerance: Duration

    public init(interval: Duration, tolerance: Duration) {
        self.interval = interval
        self.tolerance = tolerance
    }

    public static let standard = ClipboardPollingPolicy(
        interval: .milliseconds(500),
        tolerance: .milliseconds(100)
    )
}
