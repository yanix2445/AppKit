#if DEBUG
import AppKitSystem
import Foundation

/// Keeps UI tests away from the real history and the real keychain. Debug builds only.
struct UITestEnvironment {
    let storeURL: URL
    let keyService: any EncryptionKeyService
    /// Tests copy here rather than on the general pasteboard, which belongs to the user.
    let pasteboardName: String

    static let identifierVariable = "APPKIT_UI_TEST_ID"
    static let deleteKeyVariable = "APPKIT_UI_TEST_DELETE_KEY"

    static var current: UITestEnvironment? {
        let environment = ProcessInfo.processInfo.environment
        guard let identifier = environment[identifierVariable] else { return nil }
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "AppKitUITests/\(identifier)", directoryHint: .isDirectory)
        let keyURL = directory.appending(path: "key")
        if environment[deleteKeyVariable] != nil {
            try? FileManager.default.removeItem(at: keyURL)
        }
        return UITestEnvironment(
            storeURL: directory.appending(path: "History.store"),
            keyService: FileKeyService(url: keyURL),
            pasteboardName: "appkit.uitest.\(identifier)"
        )
    }

    /// True when the app only hosts unit tests, which must not open any real data.
    static var isHostingUnitTests: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCTestConfigurationFilePath"] != nil && environment[identifierVariable] == nil
    }

    private struct FileKeyService: EncryptionKeyService {
        let url: URL

        func existingKey() throws -> Data? {
            try? Data(contentsOf: url)
        }

        func createKey() throws -> Data {
            let key = Data((0..<SystemEncryptionKeyService.keyByteCount).map { _ in UInt8.random(in: .min ... .max) })
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try key.write(to: url)
            return key
        }
    }
}
#endif
