import AppKitCore
import Foundation
import XCTest

/// The budgets of the search, on texts of the kind a real history holds.
final class ClipSearchIndexPerformanceTests: XCTestCase {
    private func makeIndex(count: Int) -> ClipSearchIndex {
        let words = ["bandeau", "decision", "historique", "copie", "swift", "recherche", "format", "image", "fichier", "reglage"]
        var generator = SystemRandomNumberGenerator()
        let entries = (0..<count).map { _ -> (id: UUID, text: String) in
            let length = Int.random(in: 3...200, using: &generator)
            let text = (0..<length).map { _ in words.randomElement(using: &generator) ?? "" }.joined(separator: " ")
            return (UUID(), text)
        }
        return ClipSearchIndex(entries: entries)
    }

    private func worstTime(of index: ClipSearchIndex) -> TimeInterval {
        var worst: TimeInterval = 0
        for query in ["bandeau", "bandeau swift", "absent", "reglage fichier image"] {
            let start = ContinuousClock.now
            _ = index.matches(for: query)
            let elapsed = start.duration(to: .now)
            worst = max(worst, Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18)
        }
        return worst
    }

    func testTenThousandCopiesIn50Milliseconds() {
        let index = makeIndex(count: 10_000)
        XCTAssertLessThan(worstTime(of: index), 0.05)
        measure { _ = index.matches(for: "bandeau swift") }
    }

    func testAHundredThousandCopiesIn150Milliseconds() {
        let index = makeIndex(count: 100_000)
        XCTAssertLessThan(worstTime(of: index), 0.15)
        measure { _ = index.matches(for: "bandeau swift") }
    }
}
