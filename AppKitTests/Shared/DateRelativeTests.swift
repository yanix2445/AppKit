import Foundation
import Testing
@testable import AppKitMain

@MainActor
struct DateRelativeTests {
    @Test func sameMinuteReadsAsJustNow() {
        let now = Date.now
        let description = now.addingTimeInterval(-30).relativeDescription(relativeTo: now)
        #expect(description == String(localized: "À l’instant"))
    }

    @Test func olderCopiesNameTheirAge() {
        let now = Date.now
        let description = now.addingTimeInterval(-120).relativeDescription(relativeTo: now)
        #expect(description.contains("2"))
    }
}
