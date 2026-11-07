import Foundation
import LocalAuthentication
import Security

/// Keeps the key in the data protection keychain: readable by this app alone, after the first
/// unlock of the session, and carried to a new Mac by Migration Assistant.
public struct SystemEncryptionKeyService: EncryptionKeyService {
    public static let keyByteCount = 32

    private let service: String
    private let account = "history"

    public init(service: String) {
        self.service = service
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain as String: true,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    public func existingKey() throws -> Data? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        // Never asks the user: a key that cannot be read now counts as unavailable.
        let context = LAContext()
        context.interactionNotAllowed = true
        query[kSecUseAuthenticationContext as String] = context
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        case errSecInteractionNotAllowed, errSecAuthFailed:
            throw EncryptionKeyError.unavailable
        default:
            throw EncryptionKeyError.failed(status)
        }
    }

    public func createKey() throws -> Data {
        var bytes = [UInt8](repeating: 0, count: Self.keyByteCount)
        let randomStatus = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard randomStatus == errSecSuccess else {
            throw EncryptionKeyError.failed(randomStatus)
        }
        let key = Data(bytes)

        try delete()
        var query = baseQuery
        query[kSecValueData as String] = key
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecAttrSynchronizable as String] = false
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return key
        case errSecInteractionNotAllowed:
            throw EncryptionKeyError.unavailable
        default:
            throw EncryptionKeyError.failed(status)
        }
    }

    public func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw status == errSecInteractionNotAllowed
                ? EncryptionKeyError.unavailable
                : EncryptionKeyError.failed(status)
        }
    }
}
