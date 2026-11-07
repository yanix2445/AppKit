/// Tells what macOS allows, without reading anything of the pasteboard.
@MainActor
public protocol ClipboardAccessService: AnyObject {
    var access: ClipboardAccess { get }
    func openSettings()
}
