import AppKit
import ApplicationServices
import Carbon.HIToolbox

@MainActor
public final class SystemDirectPasteService: DirectPasteService {
    private static let editableRoles: Set<String> = [
        kAXTextFieldRole, kAXTextAreaRole, kAXComboBoxRole,
    ]

    public init() {}

    public var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    public func focusedTarget() -> DirectPasteTarget {
        let system = AXUIElementCreateSystemWide()
        var focused: CFTypeRef?
        guard AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focused) == .success,
              let focused,
              CFGetTypeID(focused) == AXUIElementGetTypeID()
        else { return .unknown }
        let element = focused as! AXUIElement

        var role: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role) == .success,
              let role = role as? String
        else { return .unknown }
        if Self.editableRoles.contains(role) { return .editable }

        var isSettable = DarwinBoolean(false)
        let status = AXUIElementIsAttributeSettable(element, kAXValueAttribute as CFString, &isSettable)
        if status == .success && isSettable.boolValue { return .editable }
        // Web and custom views often hide their text fields behind generic roles.
        return role == "AXWebArea" || role == kAXGroupRole ? .unknown : .notEditable
    }

    public func postPaste() {
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyCode = CGKeyCode(kVK_ANSI_V)
        for isKeyDown in [true, false] {
            let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: isKeyDown)
            event?.flags = .maskCommand
            event?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }

    public func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
