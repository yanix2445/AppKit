import AppKitCore
import Foundation
import Observation

/// Which page is showing, where the arrows lead, and what the search finds.
@Observable
final class SettingsNavigation {
    private(set) var pane = SettingsPane.general
    private var backStack: [SettingsPane] = []
    private var forwardStack: [SettingsPane] = []
    var query = ""

    var canGoBack: Bool { !backStack.isEmpty }
    var canGoForward: Bool { !forwardStack.isEmpty }
    var isSearching: Bool { !ClipSearchIndex.words(in: query).isEmpty }

    /// Every word of the search must be found, as in the strip.
    var results: [SettingsSearchEntry] {
        let words = ClipSearchIndex.words(in: query)
        guard !words.isEmpty else { return [] }
        return SettingsSearchEntry.all.filter { entry in
            let text = entry.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            return words.allSatisfy(text.contains)
        }
    }

    func show(_ newPane: SettingsPane) {
        query = ""
        guard newPane != pane else { return }
        backStack.append(pane)
        forwardStack.removeAll()
        pane = newPane
    }

    func goBack() {
        guard let previous = backStack.popLast() else { return }
        forwardStack.append(pane)
        pane = previous
    }

    func goForward() {
        guard let next = forwardStack.popLast() else { return }
        backStack.append(pane)
        pane = next
    }
}
