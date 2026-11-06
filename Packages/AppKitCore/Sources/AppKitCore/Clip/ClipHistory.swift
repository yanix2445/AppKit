import Observation

/// The copies of this session, newest first. It lives in memory only.
@MainActor
@Observable
public final class ClipHistory {
    public private(set) var clips: [Clip] = []

    public init() {}

    public func insert(_ clip: Clip) {
        clips.insert(clip, at: 0)
    }
}
