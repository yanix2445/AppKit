import Foundation
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

    public func replaceAll(with clips: [Clip]) {
        self.clips = clips
    }

    /// Puts a newer state of a copy in place of the old one, at the same position.
    public func update(_ clip: Clip) {
        guard let index = clips.firstIndex(where: { $0.id == clip.id }) else { return }
        clips[index] = clip
    }

    public func clip(withID id: Clip.ID) -> Clip? {
        clips.first { $0.id == id }
    }

    public func remove(_ id: Clip.ID) {
        clips.removeAll { $0.id == id }
    }

    /// Moves a copy back to the top with a new date, keeping a single entry.
    public func promote(_ id: Clip.ID, at date: Date) {
        guard let index = clips.firstIndex(where: { $0.id == id }) else { return }
        let clip = clips.remove(at: index)
        clips.insert(
            Clip(id: clip.id, content: clip.content, source: clip.source, capturedAt: date),
            at: 0
        )
    }
}
