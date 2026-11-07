import AppKitSystem
import Foundation

/// Tells by ear what became of a copy, without anything of its content.
final class CopyFeedbackController {
    static let keptEnabledKey = "soundKeptEnabled"
    static let keptNameKey = "soundKeptName"
    static let discardedEnabledKey = "soundDiscardedEnabled"
    static let discardedNameKey = "soundDiscardedName"
    static let defaultKeptName = "Tink"
    static let defaultDiscardedName = "Pop"
    /// The sounds of macOS in /System/Library/Sounds.
    static let soundNames = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]

    private let sounds: any SoundService
    private let defaults: UserDefaults

    init(sounds: any SoundService, defaults: UserDefaults) {
        self.sounds = sounds
        self.defaults = defaults
    }

    func copyWasKept() {
        play(enabledKey: Self.keptEnabledKey, nameKey: Self.keptNameKey, defaultName: Self.defaultKeptName)
    }

    func copyWasDiscarded() {
        play(enabledKey: Self.discardedEnabledKey, nameKey: Self.discardedNameKey, defaultName: Self.defaultDiscardedName)
    }

    /// Lets the user hear a sound while choosing it.
    func preview(named name: String) {
        sounds.play(named: name)
    }

    private func play(enabledKey: String, nameKey: String, defaultName: String) {
        guard defaults.object(forKey: enabledKey) as? Bool ?? true else { return }
        sounds.play(named: defaults.string(forKey: nameKey) ?? defaultName)
    }
}
