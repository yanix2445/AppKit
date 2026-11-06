import AppKitCore

/// Registers one shortcut that works from any app.
@MainActor
public protocol HotKeyService: AnyObject {
    /// Replaces the current shortcut. On failure, no shortcut stays registered.
    func register(_ combination: HotKeyCombination, onTrigger: @escaping @MainActor () -> Void) throws
    func unregister()
    func isAvailable(_ combination: HotKeyCombination) -> Bool
}
