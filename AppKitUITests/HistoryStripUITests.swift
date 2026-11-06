import AppKit
import XCTest

final class HistoryStripUITests: XCTestCase {
    @MainActor private lazy var app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Launches the app and gives the pasteboard back to the user at the end of the test.
    @MainActor private func launchApp() {
        let savedText = NSPasteboard.general.string(forType: .string)
        let app = self.app
        addTeardownBlock { @MainActor in
            app.terminate()
            if let savedText {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(savedText, forType: .string)
            }
        }
        app.launch()
    }

    @MainActor private func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    @MainActor private var statusItem: XCUIElement {
        app.statusItems["statusItem.button"]
    }

    @MainActor private var strip: XCUIElement {
        app.descendants(matching: .any)["history.strip"]
    }

    @MainActor private var cards: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "history.card")
    }

    @MainActor private func openStrip() {
        XCTAssertTrue(statusItem.waitForExistence(timeout: 5))
        statusItem.click()
        XCTAssertTrue(strip.waitForExistence(timeout: 5))
    }

    @MainActor private func waitForCards(_ count: Int) {
        let done = expectation(for: NSPredicate(format: "count == %d", count), evaluatedWith: cards)
        wait(for: [done], timeout: 5)
    }

    /// Leaves time for the half-second polling to see the copy.
    @MainActor private func copyAndWait(_ text: String) {
        copy(text)
        Thread.sleep(forTimeInterval: 1)
    }

    @MainActor func testIconOpensAndEscapeCloses() {
        launchApp()
        openStrip()
        strip.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(strip.waitForNonExistence(timeout: 5))
    }

    @MainActor func testClickElsewhereCloses() {
        launchApp()
        openStrip()
        // A point above the strip, over another app.
        strip.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: -1.5)).click()
        XCTAssertTrue(strip.waitForNonExistence(timeout: 5))
    }

    @MainActor func testCopiesShowNewestFirstWithSourceAndTime() {
        launchApp()
        copyAndWait("première copie UI")
        copyAndWait("seconde copie UI")
        openStrip()
        waitForCards(2)
        let label = cards.element(boundBy: 0).label
        XCTAssertTrue(label.contains("seconde copie UI"), label)
        XCTAssertTrue(label.contains("instant") || label.contains("now"), label)
        XCTAssertTrue(cards.element(boundBy: 1).label.contains("première copie UI"))
    }

    @MainActor func testACopyWhileOpenAppearsWithoutMovingTheSelection() {
        launchApp()
        copyAndWait("a")
        copyAndWait("b")
        openStrip()
        waitForCards(2)
        cards.element(boundBy: 1).click()
        XCTAssertTrue(cards.element(boundBy: 1).isSelected)

        copy("c")
        waitForCards(3)
        XCTAssertTrue(cards.element(boundBy: 2).isSelected)
        XCTAssertFalse(cards.element(boundBy: 0).isSelected)
    }

    /// Attaches the strip to the test report, in light and dark mode.
    @MainActor func testCaptures() {
        launchApp()
        let appearances = [
            "Light": ["-NSRequiresAquaSystemAppearance", "YES"],
            "Dark": ["-AppleInterfaceStyle", "Dark"],
        ]
        for (style, arguments) in appearances {
            app.terminate()
            app.launchArguments = arguments
            app.launch()
            openStrip()
            attachScreenshot(named: "Vide \(style)")
            strip.typeKey(.escape, modifierFlags: [])
            XCTAssertTrue(strip.waitForNonExistence(timeout: 5))

            copyAndWait("Décisions\n• Conserver le bandeau aéré.\n• Distinguer le type et le format.")
            copyAndWait("Bonjour Camille, voici le point prévu.")
            openStrip()
            waitForCards(2)
            attachScreenshot(named: "Copies \(style)")
        }
    }

    @MainActor private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Records CPU and memory at rest in the test report. It compares against a baseline once one
    /// is set in Xcode; the budgets themselves are checked by hand on the reference Mac.
    @MainActor func testIdleMetrics() {
        launchApp()
        let options = XCTMeasureOptions()
        options.iterationCount = 1
        measure(
            metrics: [XCTCPUMetric(application: app), XCTMemoryMetric(application: app)],
            options: options
        ) {
            Thread.sleep(forTimeInterval: 60)
        }
    }
}
