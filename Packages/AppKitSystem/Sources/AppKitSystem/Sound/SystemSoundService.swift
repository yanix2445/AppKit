import AppKit

/// Plays a system sound of Apple, and stays silent when interface sound effects are off in macOS.
@MainActor
public final class SystemSoundService: SoundService {
    public init() {}

    public func play(named name: String) {
        guard interfaceSoundsAreEnabled else { return }
        NSSound(named: NSSound.Name(name))?.play()
    }

    /// macOS only writes this setting once the user has changed it: it is on until then.
    private var interfaceSoundsAreEnabled: Bool {
        UserDefaults.standard.object(forKey: "com.apple.sound.uiaudio.enabled") as? Bool ?? true
    }
}
