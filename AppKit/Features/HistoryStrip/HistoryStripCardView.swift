import AppKitCore
import SwiftUI

/// A card with everything it answers to: click, menu and VoiceOver actions.
struct HistoryStripCardView: View {
    let clip: Clip
    let item: HistoryStripItem
    let viewModel: HistoryStripViewModel
    let appearanceProvider: SourceAppAppearanceProvider
    let thumbnailProvider: ClipThumbnailProvider

    private var pinTitle: LocalizedStringKey {
        clip.isPinned ? "Désépingler" : "Épingler"
    }

    var body: some View {
        ClipCardView(
            clip: clip,
            isSelected: item == viewModel.selection,
            highlightedWords: viewModel.highlightedWords,
            appearance: appearanceProvider.appearance(forBundleIdentifier: clip.source?.bundleIdentifier),
            thumbnailProvider: thumbnailProvider
        )
        .id(item)
        // Only on the card it speaks of.
        .modifier(SelectedCardTip(isSelected: item == viewModel.selection && item.section == .history, viewModel: viewModel))
        .onTapGesture {
            viewModel.select(item)
            viewModel.choose(clip.id)
        }
        .accessibilityAction { viewModel.choose(clip.id) }
        .accessibilityActions {
            if clip.content.plainText != nil {
                Button("Coller en texte brut") { viewModel.choose(clip.id, style: .plainText) }
            }
            Button(pinTitle) { viewModel.togglePin(clip.id) }
            Button("Supprimer") { viewModel.remove(clip.id) }
        }
        .contextMenu {
            Button("Coller", systemImage: "doc.on.clipboard") { viewModel.choose(clip.id) }
                .keyboardShortcut(viewModel.combination(for: .paste)?.keyboardShortcut)
            // An image or a file has no text to paste alone.
            if clip.content.plainText != nil {
                Button("Coller en texte brut", systemImage: "textformat") { viewModel.choose(clip.id, style: .plainText) }
                    .keyboardShortcut(viewModel.combination(for: .pastePlainText)?.keyboardShortcut)
            }
            Divider()
            Button(pinTitle, systemImage: clip.isPinned ? "pin.slash" : "pin") { viewModel.togglePin(clip.id) }
                .keyboardShortcut(viewModel.combination(for: .togglePin)?.keyboardShortcut)
            Divider()
            Button("Supprimer", systemImage: "trash", role: .destructive) { viewModel.remove(clip.id) }
                .keyboardShortcut(viewModel.combination(for: .delete)?.keyboardShortcut)
                .accessibilityIdentifier("history.menu.delete")
        }
    }
}
