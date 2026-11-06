/// Whether the history can be read and written.
enum HistoryLifecycleState: Equatable {
    case starting
    case ready
    /// A history exists, but its key is not on this Mac. Nothing is erased.
    case keyMissing
    /// The keychain cannot be read for now. Capture resumes by itself.
    case keyUnavailable
    /// No room left. Capture resumes by itself.
    case diskFull

    var capturesCopies: Bool {
        self == .ready
    }

    /// Paused for a reason that may go away without the user doing anything.
    var retriesByItself: Bool {
        self == .keyUnavailable || self == .diskFull
    }
}
