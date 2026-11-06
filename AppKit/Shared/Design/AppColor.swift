import AppKit
import SwiftUI

/// The `color/*` tokens of the mockups that the system does not already provide.
enum AppColor {
    static let cardFill = dynamic(light: .white.withAlphaComponent(0.78), dark: .white.withAlphaComponent(0.08))
    static let controlFill = dynamic(light: .black.withAlphaComponent(0.05), dark: .white.withAlphaComponent(0.09))
    static let onBrandDark = Color(nsColor: .black.withAlphaComponent(0.88))
    static let onBrandDarkSecondary = Color(nsColor: .black.withAlphaComponent(0.62))
    static let onBrandLight = Color(nsColor: .white)
    static let onBrandLightSecondary = Color(nsColor: .white.withAlphaComponent(0.8))

    private static func dynamic(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        })
    }
}
