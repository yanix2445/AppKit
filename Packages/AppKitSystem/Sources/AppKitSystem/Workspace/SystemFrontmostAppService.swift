import AppKit
import AppKitCore

public struct SystemFrontmostAppService: FrontmostAppService {
    public init() {}

    public func frontmostApp() -> ClipSource? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        return ClipSource(
            name: app.localizedName ?? app.bundleIdentifier ?? "",
            bundleIdentifier: app.bundleIdentifier
        )
    }
}
