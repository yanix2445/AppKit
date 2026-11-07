import AppKitCore
import Foundation
import Testing
@testable import AppKitMain

@MainActor
struct ProtectedFolderConsentTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ProtectedFolderConsentTests-\(UUID().uuidString)"))
    }

    @Test func aPlainFolderNeedsNoConsent() {
        #expect(ProtectedFolderConsent.allowsReading("/tmp/a.png", defaults: defaults))
    }

    @Test func aProtectedFolderNeedsItsOwnConsent() {
        let documents = NSHomeDirectory() + "/Documents/a.pdf"
        let desktop = NSHomeDirectory() + "/Desktop/a.pdf"
        #expect(!ProtectedFolderConsent.allowsReading(documents, defaults: defaults))

        ProtectedFolderConsent.grant(.documents, defaults: defaults)

        #expect(ProtectedFolderConsent.allowsReading(documents, defaults: defaults))
        #expect(!ProtectedFolderConsent.allowsReading(desktop, defaults: defaults))
    }
}
