import AppKit
import SwiftUI
import Testing
@testable import AppKitMain

@MainActor
struct SourceAppAppearanceProviderTests {
    @Test func theHeaderColorComesFromTheIcon() throws {
        let appearance = SourceAppAppearanceProvider().appearance(forBundleIdentifier: "com.apple.finder")
        let color = try #require(NSColor(appearance.headerColor).usingColorSpace(.sRGB))
        // The Finder icon is blue.
        #expect(color.blueComponent > color.redComponent)
    }

    @Test func anUnknownAppStillHasAnAppearance() {
        let appearance = SourceAppAppearanceProvider().appearance(forBundleIdentifier: nil)
        #expect(appearance.icon.isValid)
    }
}
