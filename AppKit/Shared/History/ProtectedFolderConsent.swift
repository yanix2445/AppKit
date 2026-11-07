import AppKitCore
import Foundation

/// Remembers the protected folders the user agreed to let AppKit read.
enum ProtectedFolderConsent {
    /// Moves when a consent is given, so that the cards read their files again.
    static let anyGrantedKey = "protectedFolderConsentRevision"

    static func allowsReading(_ path: String, defaults: UserDefaults = .standard) -> Bool {
        guard let folder = ClipProtectedFolder.containing(path) else { return true }
        return defaults.bool(forKey: key(for: folder))
    }

    static func grant(_ folder: ClipProtectedFolder, defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: key(for: folder))
        defaults.set(defaults.integer(forKey: anyGrantedKey) + 1, forKey: anyGrantedKey)
    }

    private static func key(for folder: ClipProtectedFolder) -> String {
        "protectedFolderConsent." + folder.rawValue
    }
}
