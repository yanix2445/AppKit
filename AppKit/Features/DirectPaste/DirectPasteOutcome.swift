/// How a chosen copy reached the user.
enum DirectPasteOutcome: Equatable {
    case pasted
    /// On the pasteboard: the user presses ⌘V.
    case copied(offersEnabling: Bool)
}
