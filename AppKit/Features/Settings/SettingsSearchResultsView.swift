import SwiftUI

/// What the search of the settings finds; a click opens its page.
struct SettingsSearchResultsView: View {
    let navigation: SettingsNavigation

    var body: some View {
        let results = navigation.results
        if results.isEmpty {
            ContentUnavailableView.search(text: navigation.query)
        } else {
            let words = navigation.query.split(whereSeparator: \.isWhitespace).map(String.init)
            List(results) { entry in
                Button {
                    navigation.show(entry.pane)
                } label: {
                    HStack(spacing: Spacing.small) {
                        SettingsPaneIconView(pane: entry.pane)
                        VStack(alignment: .leading) {
                            Text(ClipSearchHighlight.attributed(entry.title, words: words))
                            Text(verbatim: entry.pane.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.result.\(entry.id)")
            }
        }
    }
}
