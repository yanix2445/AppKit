import Foundation

/// Recognizes a text that is nothing but a color: `#FF5733`, `rgb(255, 87, 51)`, `hsl(11, 100%, 60%)`.
public enum ClipColorParser {
    public static func color(in text: String) -> ClipColor? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()
        let components: (Double, Double, Double, Double)?
        if lowered.hasPrefix("#") {
            components = hex(String(lowered.dropFirst()))
        } else if let arguments = arguments(of: lowered, functions: ["rgba", "rgb"]) {
            components = rgb(arguments)
        } else if let arguments = arguments(of: lowered, functions: ["hsla", "hsl"]) {
            components = hsl(arguments)
        } else {
            components = nil
        }
        guard let components else { return nil }
        return ClipColor(
            red: components.0,
            green: components.1,
            blue: components.2,
            alpha: components.3,
            text: text
        )
    }

    private static func hex(_ digits: String) -> (Double, Double, Double, Double)? {
        guard digits.allSatisfy(\.isHexDigit) else { return nil }
        let characters = Array(digits)
        let pairs: [String]
        switch characters.count {
        case 3, 4: pairs = characters.map { String([$0, $0]) }
        case 6, 8: pairs = stride(from: 0, to: characters.count, by: 2).map { String(characters[$0...($0 + 1)]) }
        default: return nil
        }
        let values = pairs.compactMap { UInt8($0, radix: 16) }.map { Double($0) / 255 }
        guard values.count == pairs.count else { return nil }
        return (values[0], values[1], values[2], values.count == 4 ? values[3] : 1)
    }

    private static func arguments(of text: String, functions: [String]) -> [String]? {
        for function in functions where text.hasPrefix(function + "(") && text.hasSuffix(")") {
            let inner = text.dropFirst(function.count + 1).dropLast()
            return inner
                .split(whereSeparator: { $0 == "," || $0 == " " || $0 == "/" })
                .map(String.init)
        }
        return nil
    }

    private static func rgb(_ arguments: [String]) -> (Double, Double, Double, Double)? {
        guard arguments.count == 3 || arguments.count == 4 else { return nil }
        let channels = arguments.prefix(3).compactMap { channel -> Double? in
            if channel.hasSuffix("%") {
                return number(channel.dropLast()).map { $0 / 100 }
            }
            return number(channel[...]).map { $0 / 255 }
        }
        guard channels.count == 3, channels.allSatisfy((0...1).contains), let alpha = alpha(arguments) else { return nil }
        return (channels[0], channels[1], channels[2], alpha)
    }

    private static func hsl(_ arguments: [String]) -> (Double, Double, Double, Double)? {
        guard arguments.count == 3 || arguments.count == 4,
              arguments[1].hasSuffix("%"), arguments[2].hasSuffix("%"),
              let hue = number(arguments[0].replacingOccurrences(of: "deg", with: "")[...]),
              let saturation = number(arguments[1].dropLast()).map({ $0 / 100 }),
              let lightness = number(arguments[2].dropLast()).map({ $0 / 100 }),
              (0...1).contains(saturation), (0...1).contains(lightness),
              let alpha = alpha(arguments)
        else { return nil }
        let chroma = (1 - abs(2 * lightness - 1)) * saturation
        let sector = (hue.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360) / 60
        let second = chroma * (1 - abs(sector.truncatingRemainder(dividingBy: 2) - 1))
        let match = lightness - chroma / 2
        let (red, green, blue): (Double, Double, Double) = switch Int(sector) {
        case 0: (chroma, second, 0)
        case 1: (second, chroma, 0)
        case 2: (0, chroma, second)
        case 3: (0, second, chroma)
        case 4: (second, 0, chroma)
        default: (chroma, 0, second)
        }
        return (red + match, green + match, blue + match, alpha)
    }

    private static func alpha(_ arguments: [String]) -> Double? {
        guard arguments.count == 4 else { return 1 }
        let value = arguments[3].hasSuffix("%")
            ? number(arguments[3].dropLast()).map { $0 / 100 }
            : number(arguments[3][...])
        return value.flatMap { (0...1).contains($0) ? $0 : nil }
    }

    private static func number(_ text: Substring) -> Double? {
        Double(text)
    }
}
