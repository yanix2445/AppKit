import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Finds the appearance of a source app once, then keeps it.
@MainActor
final class SourceAppAppearanceProvider {
    private var cache: [String: SourceAppAppearance] = [:]

    func appearance(forBundleIdentifier bundleIdentifier: String?) -> SourceAppAppearance {
        let key = bundleIdentifier ?? ""
        if let cached = cache[key] { return cached }

        let icon: NSImage
        if let bundleIdentifier,
           let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            icon = NSWorkspace.shared.icon(forFile: url.path)
        } else {
            icon = NSWorkspace.shared.icon(for: .application)
        }
        let appearance = Self.makeAppearance(icon: icon)
        cache[key] = appearance
        return appearance
    }

    /// Averages the icon's pixels, giving the most weight to the most saturated ones.
    private static func makeAppearance(icon: NSImage) -> SourceAppAppearance {
        let side = 32
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            return SourceAppAppearance(icon: icon, headerColor: .gray, prefersDarkText: false)
        }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        icon.draw(in: NSRect(x: 0, y: 0, width: side, height: side))
        NSGraphicsContext.restoreGraphicsState()

        var (red, green, blue, totalWeight) = (0.0, 0.0, 0.0, 0.0)
        for x in 0..<side {
            for y in 0..<side {
                guard let pixel = bitmap.colorAt(x: x, y: y) else { continue }
                let weight = pixel.alphaComponent * (pixel.saturationComponent + 0.02)
                red += pixel.redComponent * weight
                green += pixel.greenComponent * weight
                blue += pixel.blueComponent * weight
                totalWeight += weight
            }
        }
        guard totalWeight > 0 else {
            return SourceAppAppearance(icon: icon, headerColor: .gray, prefersDarkText: false)
        }
        (red, green, blue) = (red / totalWeight, green / totalWeight, blue / totalWeight)
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return SourceAppAppearance(
            icon: icon,
            headerColor: Color(.sRGB, red: red, green: green, blue: blue),
            prefersDarkText: luminance > 0.55
        )
    }
}
