/// What choosing a copy in the strip does.
enum PasteMode: String, CaseIterable {
    case direct
    case copyOnly

    static let storageKey = "pasteMode"
}
