import SwiftUI

/// The sounds that tell whether a copy was kept.
struct SoundSettingsSection: View {
    let feedback: CopyFeedbackController

    @AppStorage(CopyFeedbackController.keptEnabledKey) private var keptEnabled = true
    @AppStorage(CopyFeedbackController.keptNameKey) private var keptName = CopyFeedbackController.defaultKeptName
    @AppStorage(CopyFeedbackController.discardedEnabledKey) private var discardedEnabled = true
    @AppStorage(CopyFeedbackController.discardedNameKey) private var discardedName = CopyFeedbackController.defaultDiscardedName

    var body: some View {
        Section("Copie gardée") {
            Toggle(isOn: $keptEnabled) {
                Text("Jouer un son")
                Text("Vous entendez que la copie est dans l’historique.")
            }
            .accessibilityLabel("Jouer un son pour une copie gardée")
            .accessibilityIdentifier("settings.soundKept")
            soundPicker(selection: $keptName, isEnabled: keptEnabled, label: "Son d’une copie gardée", identifier: "settings.soundKeptName")
        }

        Section("Copie écartée") {
            Toggle(isOn: $discardedEnabled) {
                Text("Jouer un son")
                Text("Vous entendez qu’une copie n’a pas été gardée, sans rien voir de son contenu.")
            }
            .accessibilityLabel("Jouer un son pour une copie écartée")
            .accessibilityIdentifier("settings.soundDiscarded")
            soundPicker(selection: $discardedName, isEnabled: discardedEnabled, label: "Son d’une copie écartée", identifier: "settings.soundDiscardedName")
        }

        Section {
            VStack(alignment: .leading) {
                Text("Effets sonores de macOS")
                Text("Aucun son n’est joué quand ils sont désactivés dans Réglages Système.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func soundPicker(selection: Binding<String>, isEnabled: Bool, label: LocalizedStringKey, identifier: String) -> some View {
        Picker("Son", selection: selection) {
            ForEach(CopyFeedbackController.soundNames, id: \.self) { Text(verbatim: $0).tag($0) }
        }
        .disabled(!isEnabled)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
        // As in Sound settings of macOS, choosing a sound lets you hear it.
        .onChange(of: selection.wrappedValue) { _, name in
            feedback.preview(named: name)
        }
    }
}
