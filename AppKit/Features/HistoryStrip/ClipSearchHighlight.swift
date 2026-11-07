import Foundation
import SwiftUI

/// Marks the words of a search in a preview.
enum ClipSearchHighlight {
    static func attributed(_ text: String, words: [String]) -> AttributedString {
        var result = AttributedString(text)
        for word in words {
            var start = text.startIndex
            while let range = text.range(of: word, options: [.caseInsensitive, .diacriticInsensitive], range: start..<text.endIndex) {
                if let lower = AttributedString.Index(range.lowerBound, within: result),
                   let upper = AttributedString.Index(range.upperBound, within: result) {
                    result[lower..<upper].foregroundColor = .accentColor
                    result[lower..<upper].font = .body.weight(.semibold)
                }
                start = range.upperBound
            }
        }
        return result
    }
}
