import SwiftUI

/// The two ways of finishing a paste, each with a picture of what it does.
struct PasteModePickerView: View {
    @Binding var selection: String

    var body: some View {
        LabeledContent {
            HStack(spacing: Spacing.medium) {
                tile(.direct, title: "Coller directement") {
                    RoundedRectangle(cornerRadius: CornerRadius.control)
                        .fill(.white)
                        .padding(Spacing.medium)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: StripMetrics.focusRingWidth, height: Spacing.medium)
                                .padding(.leading, Spacing.xLarge)
                        }
                }
                tile(.copyOnly, title: "Copier seulement") {
                    HStack(spacing: Spacing.xSmall) {
                        KeyCapView(symbol: "⌘")
                        KeyCapView(symbol: "V")
                    }
                    .foregroundStyle(AppColor.onBrandLight)
                }
            }
        } label: {
            Text("Mode de collage")
            Text("Choisissez ce qui se passe quand vous validez une copie dans le bandeau.")
        }
    }

    private func tile(_ mode: PasteMode, title: LocalizedStringKey, @ViewBuilder picture: () -> some View) -> some View {
        let isSelected = selection == mode.rawValue
        return Button {
            selection = mode.rawValue
        } label: {
            VStack(spacing: Spacing.small) {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .fill(isSelected ? Color.accentColor.gradient : Color.gray.gradient)
                    picture()
                }
                .frame(width: SettingsMetrics.pasteTileWidth, height: SettingsMetrics.pasteTileHeight)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: CornerRadius.card)
                            .strokeBorder(Color.accentColor, lineWidth: StripMetrics.focusRingWidth)
                    }
                }
                Text(title)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("settings.pasteMode.\(mode.rawValue)")
    }
}
