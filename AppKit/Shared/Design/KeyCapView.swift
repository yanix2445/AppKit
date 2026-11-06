import SwiftUI

/// A keyboard key, as drawn in the keyboard hints of the mockups.
struct KeyCapView: View {
    let symbol: String

    var body: some View {
        Text(verbatim: symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, Spacing.xSmall)
            .padding(.vertical, Spacing.xxSmall)
            .background(AppColor.controlFill, in: .rect(cornerRadius: CornerRadius.control))
    }
}
