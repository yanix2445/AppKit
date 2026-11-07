#if DEBUG
import AppKitSystem
import Foundation

/// Keeps UI tests away from the real history and the real keychain. Debug builds only.
struct UITestEnvironment {
    let storeURL: URL
    let keyService: any EncryptionKeyService
    /// Tests copy here rather than on the general pasteboard, which belongs to the user.
    let pasteboardName: String
    /// Never the real permission: tests must not paste into whatever app is in front.
    let directPasteService: any DirectPasteService
    let directPasteDefaults: UserDefaults
    /// Never the real login items of this Mac.
    let launchAtLoginService: any LaunchAtLoginService

    static let identifierVariable = "APPKIT_UI_TEST_ID"
    static let deleteKeyVariable = "APPKIT_UI_TEST_DELETE_KEY"
    static let trustedVariable = "APPKIT_UI_TEST_TRUSTED"
    static let explainVariable = "APPKIT_UI_TEST_EXPLAIN"
    static let offerLaunchAtLoginVariable = "APPKIT_UI_TEST_OFFER_LOGIN"
    static let largeThresholdVariable = "APPKIT_UI_TEST_LARGE_THRESHOLD"

    static var current: UITestEnvironment? {
        let environment = ProcessInfo.processInfo.environment
        guard let identifier = environment[identifierVariable] else { return nil }
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "AppKitUITests/\(identifier)", directoryHint: .isDirectory)
        let keyURL = directory.appending(path: "key")
        if environment[deleteKeyVariable] != nil {
            try? FileManager.default.removeItem(at: keyURL)
        }
        let defaults = UserDefaults(suiteName: "appkit.uitest.\(identifier)") ?? .standard
        // The explanation of the permission would stop every test that chooses a copy.
        defaults.set(environment[explainVariable] == nil, forKey: DirectPasteCoordinator.explanationSeenKey)
        defaults.set(environment[offerLaunchAtLoginVariable] == nil, forKey: LaunchAtLoginController.offerSeenKey)
        if let threshold = environment[largeThresholdVariable].flatMap(Int.init) {
            defaults.set(threshold, forKey: "storageLargeThreshold")
        }
        return UITestEnvironment(
            storeURL: directory.appending(path: "History.store"),
            keyService: FileKeyService(url: keyURL),
            pasteboardName: "appkit.uitest.\(identifier)",
            directPasteService: FakeDirectPasteService(isTrusted: environment[trustedVariable] != nil),
            directPasteDefaults: defaults,
            launchAtLoginService: FakeLaunchAtLoginService()
        )
    }

    /// True when the app only hosts unit tests, which must not open any real data.
    static var isHostingUnitTests: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCTestConfigurationFilePath"] != nil && environment[identifierVariable] == nil
    }

    private final class FakeDirectPasteService: DirectPasteService {
        let isTrusted: Bool

        init(isTrusted: Bool) {
            self.isTrusted = isTrusted
        }

        func focusedTarget() -> DirectPasteTarget { .editable }
        func postPaste() {}
        func openAccessibilitySettings() {}
    }

    private final class FakeLaunchAtLoginService: LaunchAtLoginService {
        var status = LaunchAtLoginStatus.disabled

        func enable() throws { status = .enabled }
        func disable() throws { status = .disabled }
        func openSystemSettings() {}
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
