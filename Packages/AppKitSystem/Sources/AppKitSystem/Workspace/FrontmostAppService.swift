import AppKitCore

/// Tells which app is in front, taken as the source of a copy.
public protocol FrontmostAppService: Sendable {
    func frontmostApp() -> ClipSource?
}
