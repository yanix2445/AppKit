import Foundation

/// Holds the key of the history.
public protocol EncryptionKeyService: Sendable {
    /// The key, or `nil` if there is none.
    func existingKey() throws -> Data?
    /// Creates a key, replacing any previous one.
    func createKey() throws -> Data
}
