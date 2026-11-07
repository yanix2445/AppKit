import Testing
@testable import AppKitMain

@MainActor
struct ClipHeaderContrastTests {
    @Test func everyHeaderColorEndsUpReadable() {
        let values = stride(from: 0.0, through: 1.0, by: 0.2)
        for red in values {
            for green in values {
                for blue in values {
                    let result = ClipHeaderContrast.readable(.init(red: red, green: green, blue: blue))
                    let contrast = ClipHeaderContrast.secondaryContrast(on: result.color, prefersDarkText: result.prefersDarkText)
                    #expect(contrast >= ClipHeaderContrast.minimumContrast, "\(red) \(green) \(blue) → \(contrast)")
                }
            }
        }
    }

    @Test func aColorAlreadyReadableStaysAsItIs() {
        let dark = ClipHeaderContrast.RGB(red: 0.1, green: 0.1, blue: 0.3)
        #expect(ClipHeaderContrast.readable(dark).color == dark)
        #expect(!ClipHeaderContrast.readable(dark).prefersDarkText)
    }

    @Test func aPaleColorGetsDarkText() {
        #expect(ClipHeaderContrast.readable(.init(red: 0.95, green: 0.9, blue: 0.5)).prefersDarkText)
    }
}
