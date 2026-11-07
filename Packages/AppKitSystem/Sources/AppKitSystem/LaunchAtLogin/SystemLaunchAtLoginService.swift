import ServiceManagement

@MainActor
public final class SystemLaunchAtLoginService: LaunchAtLoginService {
    public init() {}

    public var status: LaunchAtLoginStatus {
        switch SMAppService.mainApp.status {
        case .enabled: .enabled
        case .requiresApproval: .requiresApproval
        case .notRegistered, .notFound: .disabled
        @unknown default: .disabled
        }
    }

    public func enable() throws {
        try SMAppService.mainApp.register()
    }

    public func disable() throws {
        try SMAppService.mainApp.unregister()
    }

    public func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
