import SwiftUI

/// The small colored square of a page.
struct SettingsPaneIconView: View {
    let pane: SettingsPane

    var body: some View {
        Image(systemName: pane.symbolName)
            .font(.caption)
            .foregroundStyle(AppColor.onBrandLight)
            .frame(width: SettingsMetrics.paneIconSize, height: SettingsMetrics.paneIconSize)
            .background(pane.color, in: .rect(cornerRadius: CornerRadius.paneIcon))
            .accessibilityHidden(true)
    }
}
