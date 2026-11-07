/// Starts the app when the user logs in. macOS holds the state, as the user can change it there.
@MainActor
public protocol LaunchAtLoginService: AnyObject {
    var status: LaunchAtLoginStatus { get }
    func enable() throws
    func disable() throws
    func openSystemSettings()
}
