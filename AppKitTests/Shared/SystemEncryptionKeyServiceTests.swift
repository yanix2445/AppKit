import AppKitData
import AppKitSystem
import Foundation
import Security
import Testing
@testable import AppKitMain

/// Runs in the host app, the only place signed to reach the data protection keychain.
struct SystemEncryptionKeyServiceTests {
    private let serviceName = "yanis-harrat.AppKit.tests.\(UUID().uuidString)"

    @Test func aKeyIsCreatedKeptAndDeleted() throws {
        let service = SystemEncryptionKeyService(service: serviceName)
        defer { try? service.delete() }

        #expect(try service.existingKey() == nil)
        let key = try service.createKey()
        #expect(key.count == ClipCipher.keyByteCount)
        #expect(try service.existingKey() == key)

        try service.delete()
        #expect(try service.existingKey() == nil)
    }

    @Test func theKeyIsReadableAfterFirstUnlockAndNotBoundToThisDevice() throws {
        let service = SystemEncryptionKeyService(service: serviceName)
        defer { try? service.delete() }
        _ = try service.createKey()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain as String: true,
            kSecAttrService as String: serviceName,
            kSecReturnAttributes as String: true,
        ]
        var result: CFTypeRef?
        #expect(SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess)
        let attributes = try #require(result as? [String: Any])

        #expect(attributes[kSecAttrAccessible as String] as? String == kSecAttrAccessibleAfterFirstUnlock as String)
        #expect(attributes[kSecAttrSynchronizable as String] as? Bool != true)
    }
}
