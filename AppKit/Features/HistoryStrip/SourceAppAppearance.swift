import AppKit
import SwiftUI

/// What a card shows of its source app: the icon, and a header color drawn from it.
struct SourceAppAppearance {
    let icon: NSImage
    let headerColor: Color
    let prefersDarkText: Bool
}
