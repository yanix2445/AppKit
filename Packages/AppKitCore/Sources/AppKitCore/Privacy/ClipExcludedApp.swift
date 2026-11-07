/// An app whose copies are never kept. It is known by its identifier, never by its name.
public struct ClipExcludedApp: Equatable, Sendable, Identifiable {
    public let bundleIdentifier: String
    public let name: String

    public var id: String { bundleIdentifier }

    public init(bundleIdentifier: String, name: String) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
    }

    /// A safety net behind the markers, which some password managers forget. It applies whether
    /// or not an app is installed, so one installed later is excluded from the start.
    public static let defaults = [
        ClipExcludedApp(bundleIdentifier: "com.apple.Passwords", name: "Mots de passe"),
        ClipExcludedApp(bundleIdentifier: "com.apple.keychainaccess", name: "Trousseaux d’accès"),
        ClipExcludedApp(bundleIdentifier: "com.1password.1password", name: "1Password"),
        ClipExcludedApp(bundleIdentifier: "com.agilebits.onepassword7", name: "1Password 7"),
        ClipExcludedApp(bundleIdentifier: "com.bitwarden.desktop", name: "Bitwarden"),
        ClipExcludedApp(bundleIdentifier: "com.dashlane.Dashlane", name: "Dashlane"),
        ClipExcludedApp(bundleIdentifier: "me.proton.pass.electron", name: "Proton Pass"),
        ClipExcludedApp(bundleIdentifier: "org.keepassxc.keepassxc", name: "KeePassXC"),
        ClipExcludedApp(bundleIdentifier: "com.markmcguill.strongbox.mac", name: "Strongbox"),
        ClipExcludedApp(bundleIdentifier: "com.hicknhacksoftware.MacPass", name: "MacPass"),
        ClipExcludedApp(bundleIdentifier: "in.sinew.Enpass-Desktop", name: "Enpass"),
        ClipExcludedApp(bundleIdentifier: "com.nordsec.nordpass", name: "NordPass"),
        ClipExcludedApp(bundleIdentifier: "com.callpod.keeperformac", name: "Keeper"),
        ClipExcludedApp(bundleIdentifier: "com.lastpass.LastPass", name: "LastPass"),
        ClipExcludedApp(bundleIdentifier: "com.siber.roboform", name: "RoboForm"),
    ]

    public static var defaultIdentifiers: Set<String> {
        Set(defaults.map(\.bundleIdentifier))
    }
}
