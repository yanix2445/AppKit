import AppKitCore
import SwiftUI

/// The content of the strip: the copies, newest first.
struct HistoryStripView: View {
    let viewModel: HistoryStripViewModel
    let appearanceProvider: SourceAppAppearanceProvider
    let thumbnailProvider: ClipThumbnailProvider
    let close: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        content
            .padding(.vertical, Spacing.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.strip))
            // In a key window, the glass also draws a rectangular outline with cut corners, and
            // the cards scroll past its rounded edge. Clipping after the glass removes both.
            .clipShape(.rect(cornerRadius: CornerRadius.strip))
            .focusable()
            .focusEffectDisabled()
            .focused($isFocused)
            .onAppear { isFocused = true }
            .onMoveCommand { viewModel.moveSelection($0) }
            .onExitCommand(perform: close)
            .onKeyPress(keys: [.return]) { press in
                viewModel.chooseSelection(style: press.modifiers.contains(.shift) ? .plainText : .original)
                return .handled
            }
            .onChange(of: viewModel.history.clips.first?.id) { viewModel.historyDidChange() }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Historique des copies")
            .accessibilityIdentifier("history.strip")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.history.clips.isEmpty {
            EmptyHistoryView(openHotKey: viewModel.openHotKey)
        } else {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: Spacing.small) {
                        ForEach(viewModel.history.clips) { clip in
                            ClipCardView(
                                clip: clip,
                                isSelected: clip.id == viewModel.selectedClipID,
                                appearance: appearanceProvider.appearance(forBundleIdentifier: clip.source?.bundleIdentifier),
                                thumbnailProvider: thumbnailProvider
                            )
                            .id(clip.id)
                            .onTapGesture { viewModel.choose(clip.id) }
                            .accessibilityAction { viewModel.choose(clip.id) }
                            .accessibilityActions {
                                if clip.content.plainText != nil {
                                    Button("Coller en texte brut") { viewModel.choose(clip.id, style: .plainText) }
                                }
                            }
                            .contextMenu {
                                Button("Coller") { viewModel.choose(clip.id) }
                                    .keyboardShortcut(.return, modifiers: [])
                                // An image or a file has no text to paste alone.
                                if clip.content.plainText != nil {
                                    Button("Coller en texte brut") { viewModel.choose(clip.id, style: .plainText) }
                                        .keyboardShortcut(.return, modifiers: .shift)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                }
                .scrollIndicators(.never)
                .onChange(of: viewModel.selectedClipID) { _, selection in
                    if let selection { proxy.scrollTo(selection) }
                }
            }
        }
    }
}
