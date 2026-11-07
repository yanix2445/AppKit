import AppKitCore
import SwiftUI

/// The pinned copies, in the order the user gives them by moving them.
struct PinnedSectionView: View {
    let viewModel: HistoryStripViewModel
    let appearanceProvider: SourceAppAppearanceProvider
    let thumbnailProvider: ClipThumbnailProvider

    @State private var targetedPlace: Int?

    var body: some View {
        HStack(spacing: Spacing.small) {
            ForEach(Array(viewModel.pinnedClips.enumerated()), id: \.element.id) { place, clip in
                HistoryStripCardView(
                    clip: clip,
                    item: HistoryStripItem(clipID: clip.id, section: .pinned),
                    viewModel: viewModel,
                    appearanceProvider: appearanceProvider,
                    thumbnailProvider: thumbnailProvider
                )
                .overlay {
                    if targetedPlace == place {
                        RoundedRectangle(cornerRadius: CornerRadius.card)
                            .fill(Color.accentColor.opacity(StripMetrics.dropPlaceholderOpacity))
                            .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: StripMetrics.focusRingWidth, dash: [StripMetrics.dragPlaceholderDash]))
                            .accessibilityHidden(true)
                    }
                }
                .draggable(PinnedClipDrag(id: clip.id))
                .dropDestination(for: PinnedClipDrag.self) { drops, _ in
                    guard let drop = drops.first else { return false }
                    viewModel.movePinned(drop.id, to: place)
                    return true
                } isTargeted: { isTargeted in
                    if isTargeted {
                        targetedPlace = place
                    } else if targetedPlace == place {
                        targetedPlace = nil
                    }
                }
            }
        }
        .padding(StripMetrics.pinnedSectionInset)
        .background(AppColor.controlFill, in: .rect(cornerRadius: CornerRadius.group))
        .historyStripTip(.pin, viewModel: viewModel)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Copies épinglées")
        .accessibilityIdentifier("history.pinned")
    }
}
