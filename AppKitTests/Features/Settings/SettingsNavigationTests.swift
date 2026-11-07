import Foundation
import Testing
@testable import AppKitMain

@MainActor
struct SettingsNavigationTests {
    @Test func theArrowsWalkThroughThePagesSeen() {
        let navigation = SettingsNavigation()
        #expect(!navigation.canGoBack)
        navigation.show(.storage)
        navigation.show(.sounds)
        navigation.goBack()
        #expect(navigation.pane == .storage)
        navigation.goForward()
        #expect(navigation.pane == .sounds)
        navigation.goBack()
        navigation.show(.privacy)
        #expect(!navigation.canGoForward)
    }

    @Test func theSearchFindsWithoutAccentsOrCaseAndOpeningClearsIt() {
        let navigation = SettingsNavigation()
        navigation.query = "CATEGORIES"
        #expect(navigation.results.map(\.pane) == [.privacy])
        navigation.query = "copie volumineuses"
        #expect(navigation.results.map(\.pane) == [.storage])
        navigation.show(.storage)
        #expect(navigation.query.isEmpty)
        #expect(!navigation.isSearching)
    }
}
