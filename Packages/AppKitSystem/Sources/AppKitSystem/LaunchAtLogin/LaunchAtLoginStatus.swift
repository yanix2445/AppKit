/// What macOS says about starting the app at login.
public enum LaunchAtLoginStatus: Equatable, Sendable {
    case enabled
    /// Asked for, but waiting for the user's approval in System Settings.
    case requiresApproval
    case disabled
}
