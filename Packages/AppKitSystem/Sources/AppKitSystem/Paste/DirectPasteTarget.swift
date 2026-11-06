/// What has the keyboard focus in the app in front.
public enum DirectPasteTarget: Equatable, Sendable {
    case editable
    case notEditable
    /// Many apps do not describe their content: pasting is then worth trying.
    case unknown
}
