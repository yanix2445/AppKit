import Foundation

extension Date {
    /// « À l’instant » during the first minute, then « Il y a 2 min ».
    func relativeDescription(relativeTo now: Date = .now) -> String {
        guard now.timeIntervalSince(self) >= 60 else {
            return String(localized: "À l’instant")
        }
        let style = Date.RelativeFormatStyle(
            presentation: .numeric,
            unitsStyle: .abbreviated,
            capitalizationContext: .beginningOfSentence
        )
        return style.format(self)
    }
}
