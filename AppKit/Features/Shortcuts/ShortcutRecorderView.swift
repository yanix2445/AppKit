import AppKit
import AppKitCore
import SwiftUI

/// One shortcut: a click records the next combination typed, Escape cancels.
struct ShortcutRecorderView: View {
    let action: HotKeyAction
    let shortcuts: ShortcutsController
    /// Tells the row what went wrong, or that all is well.
    let onProblem: (String?) -> Void

    @State private var isRecording = false
    @State private var monitor: Any?

    private var combination: HotKeyCombination? { shortcuts.combination(for: action) }
    private var isDefault: Bool { combination == action.defaultCombination }

    var body: some View {
        HStack(spacing: Spacing.small) {
            Button(action: startRecording) {
                recorderLabel
                    .frame(minWidth: SettingsMetrics.recorderMinWidth, minHeight: SettingsMetrics.recorderHeight)
                    .padding(.horizontal, Spacing.small)
                    .background(AppColor.controlFill, in: .rect(cornerRadius: CornerRadius.control))
                    .overlay {
                        if isRecording {
                            RoundedRectangle(cornerRadius: CornerRadius.control)
                                .strokeBorder(Color.accentColor, lineWidth: StripMetrics.focusRingWidth)
                        }
                    }
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(action.title)
            .accessibilityValue(isRecording ? String(localized: "Tapez un raccourci…") : combination?.displayName ?? String(localized: "Aucun"))
            .accessibilityIdentifier("settings.shortcut.\(action.rawValue)")

            Button("Effacer", systemImage: "xmark", action: erase)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .disabled(combination == nil)
                .help("Effacer ce raccourci")
                .accessibilityLabel(String(localized: "Effacer : \(action.title)"))
                .accessibilityIdentifier("settings.shortcutErase.\(action.rawValue)")

            Button("Rétablir", systemImage: "arrow.counterclockwise", action: reset)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .disabled(isDefault)
                .help("Rétablir le raccourci par défaut")
                .accessibilityLabel(String(localized: "Rétablir : \(action.title)"))
                .accessibilityIdentifier("settings.shortcutReset.\(action.rawValue)")
        }
        .onDisappear(perform: stopRecording)
    }

    @ViewBuilder
    private var recorderLabel: some View {
        if isRecording {
            Text("Tapez un raccourci…")
                .font(.callout)
                .foregroundStyle(.secondary)
        } else if let combination {
            Text(verbatim: combination.displayName)
                .font(.callout.weight(.semibold))
        } else {
            Text("Aucun")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        onProblem(nil)
        shortcuts.suspendGlobalShortcuts()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            MainActor.assumeIsolated { handle(event) }
            return nil
        }
    }

    private func handle(_ event: NSEvent) {
        // Escape alone cancels; a problem leaves the recording on, to try another one.
        if event.keyCode == 53, event.modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty {
            stopRecording()
            return
        }
        guard let typed = HotKeyCombination(event: event) else { return }
        // The other global shortcuts are suspended: only what is stored can tell them apart.
        if let problem = shortcuts.set(typed, for: action) {
            onProblem(problem.message(for: typed))
            NSSound.beep()
            return
        }
        stopRecording()
    }

    private func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        shortcuts.resumeGlobalShortcuts()
    }

    private func erase() {
        stopRecording()
        onProblem(nil)
        shortcuts.erase(action)
    }

    private func reset() {
        stopRecording()
        let wanted = action.defaultCombination
        onProblem(shortcuts.reset(action)?.message(for: wanted))
    }
}
