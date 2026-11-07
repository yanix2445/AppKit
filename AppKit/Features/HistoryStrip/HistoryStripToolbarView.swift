import AppKitCore
import SwiftUI

/// The search, the categories, what is going on, and the keys that matter now.
struct HistoryStripToolbarView: View {
    @Bindable var viewModel: HistoryStripViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.small) {
            searchField
                .padding(.trailing, Spacing.medium)
            filters
            Spacer(minLength: Spacing.large)
            status
            pauseMenu
            moreMenu
        }
        .frame(height: StripMetrics.toolbarHeight)
        .onChange(of: viewModel.openingCount, initial: true) { isSearchFocused = true }
    }

    private var searchField: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(viewModel.isSearching ? .primary : .secondary)
                .accessibilityHidden(true)
            TextField("Rechercher dans l’historique", text: $viewModel.query)
                .textFieldStyle(.plain)
                .focused($isSearchFocused)
                .accessibilityIdentifier("history.search")
            if viewModel.isSearching {
                Text(verbatim: resultText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize()
                    .accessibilityIdentifier("history.resultCount")
                Button {
                    viewModel.query = ""
                    isSearchFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Effacer la recherche")
                .accessibilityIdentifier("history.clearSearch")
            }
        }
        .padding(.horizontal, Spacing.small)
        .frame(width: StripMetrics.searchFieldWidth, height: StripMetrics.toolbarHeight)
        .background(AppColor.controlFill, in: .rect(cornerRadius: CornerRadius.control))
        .overlay {
            if viewModel.isSearching {
                RoundedRectangle(cornerRadius: CornerRadius.control)
                    .strokeBorder(Color.accentColor, lineWidth: StripMetrics.focusRingWidth)
            }
        }
    }

    private var resultText: String {
        switch viewModel.resultCount {
        case 0: String(localized: "Aucun résultat")
        case 1: String(localized: "1 résultat")
        default: String(localized: "\(viewModel.resultCount) résultats")
        }
    }

    private var filters: some View {
        HStack(spacing: Spacing.small) {
            HistoryStripFilterChip(
                title: String(localized: "Tout"),
                isSelected: viewModel.category == nil,
                identifier: "history.filter.all"
            ) { viewModel.setCategory(nil) }
            ForEach(ClipCategory.allCases, id: \.self) { category in
                HistoryStripFilterChip(
                    title: category.title,
                    isSelected: viewModel.category == category,
                    identifier: "history.filter.\(category.rawValue)"
                ) { viewModel.setCategory(category) }
            }
        }
    }

    /// Without room on a small screen, the reminders of the keys go first.
    private var status: some View {
        HStack(spacing: Spacing.medium) {
            if viewModel.hasRemoval {
                removalMessage
            }
            if let text = viewModel.pause?.statusText {
                pauseMessage(text)
            }
            ViewThatFits(in: .horizontal) {
                keyHints
                Color.clear.frame(width: 0)
            }
        }
    }

    private var removalMessage: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "trash")
                .accessibilityHidden(true)
            Text("Copie supprimée")
                .fixedSize()
            Button("Annuler") { viewModel.undoRemoval() }
                .controlSize(.small)
                .accessibilityIdentifier("history.undoRemoval")
            KeyCapView(symbol: "⌘")
            KeyCapView(symbol: "Z")
        }
        .font(.callout)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("history.removed")
    }

    private func pauseMessage(_ text: String) -> some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "pause.fill")
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            Text(verbatim: text)
                .fixedSize()
                .accessibilityIdentifier("history.pauseBanner")
            Button("Reprendre") { viewModel.pause?.resume() }
                .controlSize(.small)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("history.resume")
        }
        .font(.callout)
    }

    @ViewBuilder
    private var keyHints: some View {
        HStack(spacing: Spacing.medium) {
            if viewModel.isSearching && viewModel.hasNoResults {
                keyHint(["esc"], "Effacer la recherche")
            } else {
                keyHint(.paste, "Coller")
                keyHint(.pastePlainText, "Texte brut")
                // ⌫ edits a search: ⌘⌫ then deletes the copy.
                if viewModel.query.isEmpty {
                    keyHint(.delete, "Supprimer")
                } else {
                    keyHint(["⌘", "⌫"], "Supprimer")
                }
            }
        }
        .fixedSize()
    }

    @ViewBuilder
    private func keyHint(_ action: HotKeyAction, _ title: LocalizedStringKey) -> some View {
        if let combination = viewModel.combination(for: action) {
            keyHint(combination.symbols, title)
        }
    }

    private func keyHint(_ keys: [String], _ title: LocalizedStringKey) -> some View {
        HStack(spacing: Spacing.xSmall) {
            ForEach(keys, id: \.self) { KeyCapView(symbol: $0) }
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Text(title)), \(keys.joined())"))
        .accessibilityIdentifier("history.keyHint")
    }

    private var pauseMenu: some View {
        Menu {
            if viewModel.pause?.statusText != nil {
                Button("Reprendre") { viewModel.pause?.resume() }
            } else {
                Button("Pendant 5 minutes") { viewModel.pause?.pause(for: 300) }
                Button("Pendant 1 heure") { viewModel.pause?.pause(for: 3_600) }
                Button("Jusqu’à réactivation") { viewModel.pause?.pauseUntilResumed() }
                Button("Ignorer la prochaine copie") { viewModel.pause?.ignoreNextCopy() }
            }
        } label: {
            Image(systemName: "pause.fill")
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .buttonStyle(.plain)
        .frame(width: StripMetrics.toolbarButtonSize, height: StripMetrics.toolbarButtonSize)
        .foregroundStyle(viewModel.pause?.statusText == nil ? Color.primary : Color.accentColor)
        .background(AppColor.controlFill, in: .circle)
        .fixedSize()
        .accessibilityLabel("Mettre en pause")
        .accessibilityIdentifier("history.pauseMenu")
    }

    private var moreMenu: some View {
        Menu {
            Button("Réglages…") { viewModel.openSettings() }
            Button("Quitter AppKit") { viewModel.quit() }
        } label: {
            Image(systemName: "ellipsis")
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .buttonStyle(.plain)
        .frame(width: StripMetrics.toolbarButtonSize, height: StripMetrics.toolbarButtonSize)
        .background(AppColor.controlFill, in: .circle)
        .fixedSize()
        .accessibilityLabel("Plus d’options")
        .accessibilityIdentifier("history.moreMenu")
    }
}
