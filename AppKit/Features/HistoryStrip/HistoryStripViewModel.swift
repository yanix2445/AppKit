import AppKitCore
import Observation
import SwiftUI

/// What the strip shows, the search and the filter behind it, and its selection, which new copies
/// must not move.
@MainActor
@Observable
final class HistoryStripViewModel {
    let history: ClipHistory
    var shortcuts: ShortcutsController?
    var pause: CapturePauseController?
    var tips: HistoryStripTips?

    private(set) var selection: HistoryStripItem?
    private(set) var pinnedClips: [Clip] = []
    private(set) var historyClips: [Clip] = []
    private(set) var category: ClipCategory?
    private(set) var highlightedWords: [String] = []
    /// Tells the view to give the keyboard back to the search field.
    private(set) var openingCount = 0
    /// How many removals ⌘Z can still bring back.
    private(set) var removalCount = 0

    var query = "" {
        didSet {
            if query != oldValue { applyFilters() }
            if isSearching { tips?.show(.search) }
        }
    }

    private let actions: HistoryStripActions
    private let onChoose: (Clip, ClipPasteStyle) -> Void
    @ObservationIgnored private var indexTask: Task<ClipSearchIndex, Never>?
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(
        history: ClipHistory,
        actions: HistoryStripActions = HistoryStripActions(),
        onChoose: @escaping (Clip, ClipPasteStyle) -> Void = { _, _ in }
    ) {
        self.history = history
        self.actions = actions
        self.onChoose = onChoose
        applyFilters()
        // Nothing is selected before the first opening.
        selection = nil
    }

    // MARK: What is shown

    var openHotKey: HotKeyCombination? { shortcuts?.combination(for: .openHistory) }

    /// The one chosen by the user, or `nil` when it has been erased.
    func combination(for action: HotKeyAction) -> HotKeyCombination? {
        shortcuts == nil ? action.defaultCombination : shortcuts?.combination(for: action)
    }

    var hasRemoval: Bool { removalCount > 0 }

    var isSearching: Bool { !ClipSearchIndex.words(in: query).isEmpty }

    /// Only a history entirely empty has nothing to look for.
    var isHistoryEmpty: Bool { history.clips.isEmpty }

    var hasNoResults: Bool { !isHistoryEmpty && pinnedClips.isEmpty && historyClips.isEmpty }

    /// Each copy once, even when it has two cards.
    var resultCount: Int {
        Set(pinnedClips.map(\.id) + historyClips.map(\.id)).count
    }

    private var items: [HistoryStripItem] {
        pinnedClips.map { HistoryStripItem(clipID: $0.id, section: .pinned) }
            + historyClips.map { HistoryStripItem(clipID: $0.id, section: .history) }
    }

    /// Each opening starts anew, on the newest copy.
    func prepareForPresentation() {
        category = nil
        removalCount = 0
        openingCount += 1
        query = ""
        buildIndex()
        applyFilters()
        selection = historyClips.first.map { HistoryStripItem(clipID: $0.id, section: .history) } ?? items.first
    }

    /// The index and whatever could still be brought back go at the same moment.
    func didClose() {
        searchTask?.cancel()
        indexTask = nil
        tips?.dismiss()
        removalCount = 0
        actions.commitRemovals()
    }

    func historyDidChange() {
        if indexTask != nil { buildIndex() }
        applyFilters()
    }

    func setCategory(_ category: ClipCategory?) {
        self.category = category
        applyFilters()
    }

    /// Waits for the results of the search under way.
    func searchDidFinish() async {
        await searchTask?.value
    }

    private func buildIndex() {
        let clips = history.clips
        indexTask = Task.detached { ClipSearchIndex(clips) }
    }

    private func applyFilters() {
        searchTask?.cancel()
        let words = ClipSearchIndex.words(in: query)
        guard !words.isEmpty else {
            show(matches: nil, words: [])
            return
        }
        let query = query
        let indexTask = indexTask ?? Task.detached { [clips = history.clips] in ClipSearchIndex(clips) }
        searchTask = Task {
            let index = await indexTask.value
            let matches = await Task.detached { index.matches(for: query) }.value
            guard !Task.isCancelled else { return }
            show(matches: matches, words: words)
        }
    }

    private func show(matches: Set<Clip.ID>?, words: [String]) {
        let category = category
        let isVisible: (Clip) -> Bool = { clip in
            (category == nil || ClipCategory(clip.content) == category) && matches?.contains(clip.id) != false
        }
        pinnedClips = history.pinned.filter(isVisible)
        // Looking for something, each copy is shown once: in its section if it is pinned.
        let isNarrowed = category != nil || matches != nil
        historyClips = history.clips.filter { isVisible($0) && !(isNarrowed && $0.isPinned) }
        highlightedWords = words
        keepSelectionVisible()
    }

    private func keepSelectionVisible() {
        let items = items
        if let selection, items.contains(selection) { return }
        // A copy just unpinned stays selected, at its place by date.
        selection = items.first { $0.clipID == selection?.clipID } ?? items.first
    }

    // MARK: Actions

    func choose(_ id: Clip.ID, style: ClipPasteStyle = .original) {
        guard let clip = history.clip(withID: id) else { return }
        onChoose(clip, style)
    }

    func select(_ item: HistoryStripItem) {
        selection = item
    }

    func chooseSelection(style: ClipPasteStyle = .original) {
        if let selection {
            choose(selection.clipID, style: style)
        }
    }

    func moveSelection(left: Bool) {
        let items = items
        guard let selection, let index = items.firstIndex(of: selection) else { return }
        let next = left ? index - 1 : index + 1
        if items.indices.contains(next) {
            self.selection = items[next]
        }
    }

    func togglePin(_ id: Clip.ID) {
        let isPinning = history.clip(withID: id)?.isPinned == false
        actions.togglePin(id)
        if isPinning { tips?.show(.pin) }
    }

    /// A pause may begin while the strip is open.
    func pauseDidChange() {
        if pauseIsTimedOrUntilResumed { tips?.show(.pause) }
    }

    private var pauseIsTimedOrUntilResumed: Bool {
        pause?.isPaused == true
    }

    /// The strip is in place: what its opening has to explain can show.
    func didAppear() {
        if pauseIsTimedOrUntilResumed {
            tips?.show(.pause)
        } else if selection != nil, combination(for: .paste) != nil {
            tips?.show(.paste)
        }
    }

    func text(of tip: HistoryStripTip) -> String {
        switch tip {
        case .paste:
            let paste = combination(for: .paste)?.displayName ?? "↩"
            if let plain = combination(for: .pastePlainText)?.displayName {
                return String(localized: "\(paste) colle la copie là où vous écriviez. \(plain) la colle sans mise en forme.")
            }
            return String(localized: "\(paste) colle la copie là où vous écriviez.")
        case .search:
            return String(localized: "Tapez simplement pour chercher, sans cliquer. Chaque mot compte ; les accents et les majuscules, non.")
        case .pin:
            return String(localized: "Elle reste à gauche du bandeau, n’est jamais effacée, et se glisse pour changer l’ordre.")
        case .pause:
            if case .until(let end) = pause?.pause {
                return String(localized: "Rien de ce que vous copiez n’est gardé jusqu’à \(end.formatted(date: .omitted, time: .shortened)). L’icône de la barre de menus vous le rappelle.")
            }
            return String(localized: "Rien de ce que vous copiez n’est gardé jusqu’à ce que vous repreniez. L’icône de la barre de menus vous le rappelle.")
        }
    }

    /// Moves the selected copy within the pinned section.
    func moveSelectedPinned(left: Bool) {
        guard let selection, let index = pinnedClips.firstIndex(where: { $0.id == selection.clipID }) else { return }
        movePinned(selection.clipID, to: left ? index - 1 : index + 1)
    }

    func movePinned(_ id: Clip.ID, to visiblePlace: Int) {
        // Under a filter, the section shows only part of the copies: places are counted among all.
        guard pinnedClips.indices.contains(visiblePlace) else { return }
        let target = pinnedClips[visiblePlace].id
        guard let place = history.pinned.firstIndex(where: { $0.id == target }) else { return }
        actions.movePinned(id, place)
    }

    func remove(_ id: Clip.ID) {
        let items = items
        let position = selection.flatMap { items.firstIndex(of: $0) }
        actions.remove(id)
        removalCount += 1
        // The selection stays where it was, on the next copy.
        let remaining = items.filter { $0.clipID != id }
        if selection?.clipID == id, let position, !remaining.isEmpty {
            selection = remaining[min(position, remaining.count - 1)]
        }
    }

    /// - Returns: whether there was a removal to bring back.
    @discardableResult
    func undoRemoval() -> Bool {
        guard removalCount > 0, actions.undoRemoval() else { return false }
        removalCount -= 1
        return true
    }

    func openSettings() {
        actions.openSettings()
    }

    func quit() {
        actions.quit()
    }

    // MARK: Keyboard

    /// - Returns: whether the key was used; otherwise it goes on to the search field.
    func handle(_ key: HistoryStripKey, isRepeat: Bool, close: () -> Void) -> Bool {
        switch key {
        case .escape:
            if query.isEmpty {
                close()
            } else {
                query = ""
            }
        case .choose(let plainText):
            chooseSelection(style: plainText ? .plainText : .original)
        case .move(let left):
            moveSelection(left: left)
        case .vertical:
            break
        case .delete(let command):
            // ⌫ edits a search. A key held down never goes on to erase the copies.
            guard command || query.isEmpty else { return false }
            if !isRepeat, let selection {
                remove(selection.clipID)
            }
        case .togglePin:
            if let selection { togglePin(selection.clipID) }
        case .undo:
            // Without a removal, ⌘Z is for the text of the search.
            guard undoRemoval() else { return false }
        case .movePinned(let left):
            moveSelectedPinned(left: left)
        case .filter(let number):
            setCategory(number == 0 ? nil : ClipCategory.allCases[number - 1])
        }
        return true
    }
}
