import Foundation
import Observation

/// The copies of this session, newest first. It lives in memory only.
@MainActor
@Observable
public final class ClipHistory {
    public private(set) var clips: [Clip] = [] {
        didSet { revision += 1 }
    }
    /// Changes with every change of the copies, cheaper to watch than the copies themselves.
    public private(set) var revision = 0

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
        guard let clip = clips.first(where: { $0.id == id }) else { return }
        moveToTop(clip.replacing(capturedAt: date))
    }

    /// Puts a newer state of a copy at the top, in place of the old one.
    public func moveToTop(_ clip: Clip) {
        clips.removeAll { $0.id == clip.id }
        clips.insert(clip, at: 0)
    }

    /// Puts back a copy that had been removed, at its place by date.
    public func restore(_ clip: Clip) {
        let index = clips.firstIndex { $0.capturedAt < clip.capturedAt } ?? clips.count
        clips.insert(clip, at: index)
    }

    /// The pinned copies, from the left of their section.
    public var pinned: [Clip] {
        clips.filter(\.isPinned).sorted { $0.pinOrder < $1.pinOrder }
    }

    /// Pins a copy at the end of the section, or unpins it.
    /// - Returns: its new state.
    public func togglePin(_ id: Clip.ID) -> Clip? {
        guard let clip = clip(withID: id) else { return nil }
        let order = (pinned.last?.pinOrder ?? -1) + 1
        let changed = clip.isPinned
            ? clip.replacing(isPinned: false, pinOrder: 0)
            : clip.replacing(isPinned: true, pinOrder: order)
        update(changed)
        return changed
    }

    /// Moves a pinned copy to a new place in its section.
    /// - Returns: the copies whose place has changed.
    public func movePinned(_ id: Clip.ID, to place: Int) -> [Clip] {
        var section = pinned
        guard let current = section.firstIndex(where: { $0.id == id }) else { return [] }
        let target = min(max(place, 0), section.count - 1)
        guard target != current else { return [] }
        section.insert(section.remove(at: current), at: target)
        var changed: [Clip] = []
        for (order, clip) in section.enumerated() where clip.pinOrder != order {
            let moved = clip.replacing(pinOrder: order)
            update(moved)
            changed.append(moved)
        }
        return changed
    }
}
