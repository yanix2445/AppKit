import AppKitCore

/// A card of the strip. A pinned copy can have two: in its section and at its place by date.
struct HistoryStripItem: Identifiable, Hashable {
    enum Section: Hashable {
        case pinned, history
    }

    let clipID: Clip.ID
    let section: Section

    var id: Self { self }
}
