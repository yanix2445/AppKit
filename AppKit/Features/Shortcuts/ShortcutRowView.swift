import AppKitCore
import SwiftUI

/// An action, its shortcut and, below its name, why a new one was refused.
struct ShortcutRowView: View {
    let action: HotKeyAction
    let shortcuts: ShortcutsController
    var subtitle: LocalizedStringKey?

    @State private var problem: String?

    var body: some View {
        LabeledContent {
            ShortcutRecorderView(action: action, shortcuts: shortcuts) { problem = $0 }
        } label: {
            Text(verbatim: action.title)
            if let problem {
                Text(verbatim: problem)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("settings.shortcutProblem.\(action.rawValue)")
            } else if let subtitle {
                Text(subtitle)
            }
        }
    }
}
