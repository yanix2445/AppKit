import AppKitCore

/// Whether a chosen copy could go back on the pasteboard.
enum ClipRestoreOutcome: Equatable {
    case restored
    /// Every file it refers to has moved or gone.
    case filesMissing
    /// Its content could not be read from the disk.
    case unreadable

    /// What can be told before touching the pasteboard, which must keep its content on a failure.
    static func check(_ clip: Clip, formats: [ClipRepresentation]) -> ClipRestoreOutcome {
        if case .files(let files) = clip.content, !files.contains(where: \.exists) {
            return .filesMissing
        }
        if clip.content.plainText == nil && formats.isEmpty {
            return .unreadable
        }
        return .restored
    }
}
