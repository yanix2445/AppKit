import AppKitCore
import Carbon.HIToolbox

/// Uses `RegisterEventHotKey`, which needs no permission. Registering it as exclusive makes macOS
/// refuse a shortcut that another app already holds in the same way.
@MainActor
public final class SystemHotKeyService: HotKeyService {
    private static let signature: OSType = 0x41504B54 // "APKT"
    private static var nextIdentifier: UInt32 = 1

    /// Each service holds one shortcut, and answers only to its own.
    private let identifier: UInt32

    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    private var onTrigger: (@MainActor () -> Void)?

    public init() {
        identifier = Self.nextIdentifier
        Self.nextIdentifier += 1
    }

    public func register(_ combination: HotKeyCombination, onTrigger: @escaping @MainActor () -> Void) throws {
        unregister()
        guard !Self.isReservedBySystem(combination) else { throw HotKeyError.alreadyTaken }
        hotKeyRef = try Self.makeHotKey(combination, identifier: identifier)
        self.onTrigger = onTrigger
        installHandlerIfNeeded()
    }

    public func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRef = nil
        onTrigger = nil
    }

    public func isAvailable(_ combination: HotKeyCombination) -> Bool {
        guard !Self.isReservedBySystem(combination),
              let probe = try? Self.makeHotKey(combination, identifier: identifier)
        else { return false }
        UnregisterEventHotKey(probe)
        return true
    }

    private static func makeHotKey(_ combination: HotKeyCombination, identifier: UInt32) throws -> EventHotKeyRef? {
        var reference: EventHotKeyRef?
        let status = RegisterEventHotKey(
            combination.keyCode,
            carbonModifiers(combination.modifiers),
            EventHotKeyID(signature: signature, id: identifier),
            GetEventDispatcherTarget(),
            OptionBits(kEventHotKeyExclusive),
            &reference
        )
        switch status {
        case noErr: return reference
        case OSStatus(eventHotKeyExistsErr): throw HotKeyError.alreadyTaken
        default: throw HotKeyError.failed(status)
        }
    }

    private func installHandlerIfNeeded() {
        guard handlerRef == nil else { return }
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, context in
                guard let context, let event else { return OSStatus(eventNotHandledErr) }
                var pressed = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &pressed
                )
                let service = Unmanaged<SystemHotKeyService>.fromOpaque(context).takeUnretainedValue()
                return MainActor.assumeIsolated {
                    // Left to the handler of the service that holds this shortcut.
                    guard status == noErr, pressed.id == service.identifier else { return OSStatus(eventNotHandledErr) }
                    service.onTrigger?()
                    return noErr
                }
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &handlerRef
        )
    }

    /// Shortcuts of macOS itself, as set in System Settings.
    private static func isReservedBySystem(_ combination: HotKeyCombination) -> Bool {
        var reference: Unmanaged<CFArray>?
        guard CopySymbolicHotKeys(&reference) == noErr,
              let entries = reference?.takeRetainedValue() as? [[String: Any]]
        else { return false }
        let modifiers = Int(carbonModifiers(combination.modifiers))
        return entries.contains { entry in
            (entry[kHISymbolicHotKeyEnabled as String] as? Bool) == true
                && (entry[kHISymbolicHotKeyCode as String] as? Int) == Int(combination.keyCode)
                && (entry[kHISymbolicHotKeyModifiers as String] as? Int) == modifiers
        }
    }

    private static func carbonModifiers(_ modifiers: HotKeyModifiers) -> UInt32 {
        var result = 0
        if modifiers.contains(.command) { result |= cmdKey }
        if modifiers.contains(.shift) { result |= shiftKey }
        if modifiers.contains(.option) { result |= optionKey }
        if modifiers.contains(.control) { result |= controlKey }
        return UInt32(result)
    }
}
