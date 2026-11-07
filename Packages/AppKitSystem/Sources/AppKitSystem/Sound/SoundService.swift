/// Plays the short sounds that tell what happened to a copy.
@MainActor
public protocol SoundService: AnyObject {
    func play(named name: String)
}
