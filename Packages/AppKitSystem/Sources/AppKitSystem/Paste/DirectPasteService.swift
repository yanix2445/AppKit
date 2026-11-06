/// Pastes into the app in front, which needs the Accessibility permission.
@MainActor
public protocol DirectPasteService: AnyObject {
    /// Read each time: a permission granted later counts from the next paste.
    var isTrusted: Bool { get }
    func focusedTarget() -> DirectPasteTarget
    func postPaste()
    func openAccessibilitySettings()
}
