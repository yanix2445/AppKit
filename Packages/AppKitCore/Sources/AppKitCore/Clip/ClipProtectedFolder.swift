import Foundation

/// A folder for which macOS asks the user before an app reads its files.
public enum ClipProtectedFolder: String, CaseIterable, Sendable {
    case desktop = "Desktop"
    case documents = "Documents"
    case downloads = "Downloads"

    /// The protected folder holding a path, if any.
    public static func containing(_ path: String, home: String = NSHomeDirectory()) -> ClipProtectedFolder? {
        allCases.first { path.hasPrefix(home + "/" + $0.rawValue + "/") }
    }
}
