import AppKitCore
import SwiftUI

/// The content of the strip: its toolbar, then the pinned copies and the others, newest first.
struct HistoryStripView: View {
    let viewModel: HistoryStripViewModel
    let appearanceProvider: SourceAppAppearanceProvider
    let thumbnailProvider: ClipThumbnailProvider

    var body: some View {
        VStack(spacing: Spacing.medium - StripMetrics.pinnedSectionInset) {
            HistoryStripToolbarView(viewModel: viewModel)
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.strip))
        // In a key window, the glass also draws a rectangular outline with cut corners, and
        // the cards scroll past its rounded edge. Clipping after the glass removes both.
        .clipShape(.rect(cornerRadius: CornerRadius.strip))
        .onChange(of: viewModel.history.revision) { viewModel.historyDidChange() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Historique des copies")
        .accessibilityIdentifier("history.strip")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isHistoryEmpty {
            EmptyHistoryView(openHotKey: viewModel.openHotKey)
        } else if viewModel.hasNoResults {
            NoResultsView(viewModel: viewModel)
        } else {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: Spacing.small) {
                        if !viewModel.pinnedClips.isEmpty {
                            PinnedSectionView(
                                viewModel: viewModel,
                                appearanceProvider: appearanceProvider,
                                thumbnailProvider: thumbnailProvider
                            )
                        }
                        ForEach(viewModel.historyClips) { clip in
                            HistoryStripCardView(
                                clip: clip,
                                item: HistoryStripItem(clipID: clip.id, section: .history),
                                viewModel: viewModel,
                                appearanceProvider: appearanceProvider,
                                thumbnailProvider: thumbnailProvider
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, StripMetrics.pinnedSectionInset)
                }
                .scrollIndicators(.never)
                .onChange(of: viewModel.selection) { _, selection in
                    if let selection { proxy.scrollTo(selection) }
                }
            }
        }
    }
}
