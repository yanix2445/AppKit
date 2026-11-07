import AppKitCore

/// What the strip asks of the rest of the app.
struct HistoryStripActions {
    var togglePin: (Clip.ID) -> Void = { _ in }
    var movePinned: (Clip.ID, Int) -> Void = { _, _ in }
    var remove: (Clip.ID) -> Void = { _ in }
    /// Tells whether there was a removal to undo.
    var undoRemoval: () -> Bool = { false }
    var commitRemovals: () -> Void = {}
    var openSettings: () -> Void = {}
    var quit: () -> Void = {}
}
