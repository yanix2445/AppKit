import CryptoKit
import Foundation

/// Seals the content of the history with AES-256-GCM. Each block is bound to its record,
/// so a block moved to another record no longer opens.
public struct ClipCipher: Sendable {
    public static let keyByteCount = 32

    private let key: SymmetricKey

    public init(keyData: Data) throws {
        guard keyData.count == Self.keyByteCount else {
            throw ClipStoreError.invalidKey
        }
        key = SymmetricKey(data: keyData)
    }

    func seal(_ data: Data, for id: UUID) throws -> Data {
        guard let combined = try AES.GCM.seal(data, using: key, authenticating: Self.bytes(of: id)).combined else {
            throw ClipStoreError.invalidKey
        }
        return combined
    }

    func open(_ sealed: Data, for id: UUID) throws -> Data {
        try AES.GCM.open(AES.GCM.SealedBox(combined: sealed), using: key, authenticating: Self.bytes(of: id))
    }

    private static func bytes(of id: UUID) -> Data {
        withUnsafeBytes(of: id.uuid) { Data($0) }
    }
}
