import AppKitCore
import Observation
import SwiftUI

/// The selection of the strip, which new copies must not move.
@MainActor
@Observable
final class HistoryStripViewModel {
    let history: ClipHistory
    private(set) var selectedClipID: Clip.ID?
    var openHotKey: HotKeyCombination?
    var pauseBanner: String?
    var onResume: (() -> Void)?
    private let onChoose: (Clip, ClipPasteStyle) -> Void

    init(history: ClipHistory, onChoose: @escaping (Clip, ClipPasteStyle) -> Void = { _, _ in }) {
        self.history = history
        self.onChoose = onChoose
    }

    /// Each opening starts on the newest copy.
    func prepareForPresentation() {
        selectedClipID = history.clips.first?.id
    }

    /// The first copy of an empty strip becomes the selection; later ones leave it alone.
    func historyDidChange() {
        if selectedClipID == nil {
            selectedClipID = history.clips.first?.id
        }
    }

    func choose(_ id: Clip.ID, style: ClipPasteStyle = .original) {
        guard let clip = history.clips.first(where: { $0.id == id }) else { return }
        selectedClipID = id
        onChoose(clip, style)
    }

    func chooseSelection(style: ClipPasteStyle = .original) {
        if let selectedClipID {
            choose(selectedClipID, style: style)
        }
    }

    func moveSelection(_ direction: MoveCommandDirection) {
        let clips = history.clips
        guard let selectedClipID,
              let index = clips.firstIndex(where: { $0.id == selectedClipID })
        else { return }
        switch direction {
        case .left where index > 0:
            self.selectedClipID = clips[index - 1].id
        case .right where index < clips.count - 1:
            self.selectedClipID = clips[index + 1].id
        default:
            break
        }
    }
}
