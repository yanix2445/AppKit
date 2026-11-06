import Security

public enum EncryptionKeyError: Error, Equatable {
    /// The keychain cannot be read for now, typically before the first unlock of the session.
    case unavailable
    case failed(OSStatus)
}
