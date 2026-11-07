import AppKit
import AppKitCore

/// Warns that macOS is about to ask for access, before AppKit reads a copied file.
@MainActor
final class ProtectedFolderAlertPresenter {
    /// Asks once per folder, for the first file that needs it.
    func explainIfNeeded(for files: [ClipFile], defaults: UserDefaults = .standard) {
        guard let file = files.first(where: { !ProtectedFolderConsent.allowsReading($0.path, defaults: defaults) }),
              let folder = ClipProtectedFolder.containing(file.path)
        else { return }

        NSApp.activate()
        let name = folderName(folder)
        let alert = NSAlert()
        alert.messageText = String(localized: "macOS va vous demander l’accès au dossier \(name)")
        alert.informativeText = [
            String(localized: "Vous avez copié « \(file.name) », rangé dans \(name). Pour l’afficher et le recoller, AppKit doit lire ce fichier."),
            String(localized: "AppKit ne lit que les fichiers que vous copiez, rien d’autre."),
        ].joined(separator: "\n\n")
        alert.addButton(withTitle: String(localized: "Continuer"))
        alert.addButton(withTitle: String(localized: "Pas maintenant"))
        if alert.runModal() == .alertFirstButtonReturn {
            ProtectedFolderConsent.grant(folder, defaults: defaults)
        }
    }

    private func folderName(_ folder: ClipProtectedFolder) -> String {
        switch folder {
        case .desktop: String(localized: "Bureau")
        case .documents: String(localized: "Documents")
        case .downloads: String(localized: "Téléchargements")
        }
    }
}
