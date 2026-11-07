import Foundation

/// Keeps the text of a card header readable, whatever color the app icon gives it: the secondary
/// text, the faintest one, reaches the contrast of 4.5:1 that Apple asks for.
enum ClipHeaderContrast {
    struct RGB: Equatable {
        var red: Double
        var green: Double
        var blue: Double

        func mixed(with other: Double, by amount: Double) -> RGB {
            RGB(
                red: red + (other - red) * amount,
                green: green + (other - green) * amount,
                blue: blue + (other - blue) * amount
            )
        }

        /// Relative luminance, as defined by WCAG.
        var luminance: Double {
            func linear(_ value: Double) -> Double {
                value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
        }

        func contrast(with other: RGB) -> Double {
            let lighter = max(luminance, other.luminance)
            let darker = min(luminance, other.luminance)
            return (lighter + 0.05) / (darker + 0.05)
        }
    }

    static let minimumContrast = 4.5
    static let lightSecondaryOpacity = 0.8
    static let darkSecondaryOpacity = 0.62
    private static let step = 0.05

    /// The header color nearest to the given one, and whether its text is dark.
    static func readable(_ color: RGB) -> (color: RGB, prefersDarkText: Bool) {
        let prefersDarkText = color.contrast(with: RGB(red: 0, green: 0, blue: 0)) > color.contrast(with: RGB(red: 1, green: 1, blue: 1))
        var adjusted = color
        // Light text calls for a darker header, and dark text for a lighter one.
        while secondaryContrast(on: adjusted, prefersDarkText: prefersDarkText) < minimumContrast {
            adjusted = adjusted.mixed(with: prefersDarkText ? 1 : 0, by: step)
        }
        return (adjusted, prefersDarkText)
    }

    static func secondaryContrast(on color: RGB, prefersDarkText: Bool) -> Double {
        let text = prefersDarkText
            ? color.mixed(with: 0, by: darkSecondaryOpacity)
            : color.mixed(with: 1, by: lightSecondaryOpacity)
        return text.contrast(with: color)
    }
}
