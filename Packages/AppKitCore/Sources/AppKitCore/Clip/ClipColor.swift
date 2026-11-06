/// A copied color, with the text to paste back and to show.
public struct ClipColor: Equatable, Codable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    public let text: String

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1, text: String) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.text = text
    }

    /// A color without any text of its own reads as `#RRGGBB`.
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        let hex = [red, green, blue]
            .map { component in
                let value = Int((min(max(component, 0), 1) * 255).rounded())
                let digits = String(value, radix: 16, uppercase: true)
                return digits.count == 1 ? "0" + digits : digits
            }
            .joined()
        self.init(red: red, green: green, blue: blue, alpha: alpha, text: "#" + hex)
    }
}
