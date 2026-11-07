import AppKitCore
import SwiftUI

/// Attaches an explanation to what it is about.
struct HistoryStripTipModifier: ViewModifier {
    let tip: HistoryStripTip
    let viewModel: HistoryStripViewModel

    private var isPresented: Binding<Bool> {
        Binding(
            get: { viewModel.tips?.active == tip },
            set: { if !$0 { viewModel.tips?.dismiss() } }
        )
    }

    func body(content: Content) -> some View {
        content.popover(isPresented: isPresented, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                if tip == .pin {
                    Text("Copie épinglée")
                        .font(.headline)
                }
                Text(verbatim: viewModel.text(of: tip))
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("history.tip.\(tip.rawValue)")
                HStack {
                    Spacer()
                    Button("Compris") { viewModel.tips?.dismiss() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .accessibilityIdentifier("history.tipDone")
                }
            }
            .padding(Spacing.medium)
            .frame(width: StripMetrics.tipWidth)
        }
    }
}

extension View {
    func historyStripTip(_ tip: HistoryStripTip, viewModel: HistoryStripViewModel) -> some View {
        modifier(HistoryStripTipModifier(tip: tip, viewModel: viewModel))
    }
}
