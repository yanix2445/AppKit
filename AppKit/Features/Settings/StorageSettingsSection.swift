import AppKitCore
import SwiftUI

/// The room taken by the history, and the rules that keep it within limits.
struct StorageSettingsSection: View {
    let viewModel: StorageSettingsViewModel

    private static let thresholds = [50_000_000, 100_000_000, 200_000_000, 500_000_000, 1_000_000_000]
    private static let lifetimes: [TimeInterval] = [3_600, 21_600, 86_400, 259_200, 604_800]

    private var policy: ClipStoragePolicy { viewModel.policy }

    var body: some View {
        Section("Stockage") {
            LabeledContent {
                Text(verbatim: "\(bytes(viewModel.usage.historyBytes)) / \(bytes(policy.limitBytes))")
                    .accessibilityIdentifier("settings.storageUsage")
            } label: {
                Text("Historique")
                Text(summary)
            }
            ProgressView(value: min(Double(viewModel.usage.historyBytes), Double(policy.limitBytes)), total: Double(policy.limitBytes))
                .accessibilityLabel("Place occupée par l’historique")

            Picker(selection: changing(\.retention)) {
                ForEach(ClipRetention.allCases, id: \.self) { Text(title(of: $0)).tag($0) }
            } label: {
                Text("Durée de conservation")
                Text("Les copies plus anciennes sont supprimées, sauf les épinglées.")
            }
            .accessibilityIdentifier("settings.retention")

            Stepper(value: changing(\.limitInGigabytes), in: ClipStoragePolicy.limitRange) {
                Text("Limite de stockage : \(policy.limitInGigabytes) Go")
                Text("De 1 Go à 10 Go.")
            }
            .accessibilityIdentifier("settings.limit")

            Picker(selection: threshold) {
                ForEach(thresholdChoices, id: \.self) { Text(bytes($0)).tag($0) }
            } label: {
                Text("Seuil des copies volumineuses")
                Text("Au-delà, une copie est gardée à part et ne compte pas dans la limite.")
            }

            Picker(selection: changing(\.largeLifetime)) {
                ForEach(Self.lifetimes, id: \.self) { Text(duration($0)).tag($0) }
            } label: {
                Text("Durée des copies volumineuses")
                Text("Elle est aussi supprimée dès qu’une autre copie volumineuse arrive.")
            }

            LabeledContent {
                Button("Tout effacer…", role: .destructive) {
                    Task { await viewModel.requestErase() }
                }
                .accessibilityIdentifier("settings.eraseAll")
            } label: {
                Text("Effacer tout l’historique")
                Text("Les épinglés et les copies volumineuses ne sont pas touchés.")
            }
        }
        .task { await viewModel.refresh() }
        .alert(alertTitle, isPresented: isConfirming, presenting: viewModel.pendingChange) { change in
            Button("Annuler", role: .cancel) { viewModel.cancelPendingChange() }
            Button(change.policy == nil ? "Tout effacer" : "Supprimer", role: .destructive) {
                Task { await viewModel.confirm(change) }
            }
        } message: { change in
            Text(change.policy == nil
                ? "Tout l’historique sera effacé. Les éléments épinglés et les copies volumineuses temporaires ne sont pas touchés."
                : "Les éléments épinglés et les copies volumineuses temporaires ne sont pas touchés.")
        }
    }

    private var alertTitle: String {
        guard let impact = viewModel.pendingChange?.impact else { return "" }
        return String(localized: "Supprimer \(impact.ids.count) éléments (\(bytes(impact.byteCount))) ?")
    }

    private var isConfirming: Binding<Bool> {
        Binding(
            get: { viewModel.pendingChange != nil },
            set: { if !$0 { viewModel.cancelPendingChange() } }
        )
    }

    private var summary: String {
        let usage = viewModel.usage
        return usage.pinnedCount == 0
            ? String(localized: "\(usage.copyCount) copies.")
            : String(localized: "\(usage.copyCount) copies, dont \(usage.pinnedCount) épinglées. Les épinglées ne comptent pas dans la limite.")
    }

    private var thresholdChoices: [Int] {
        Array(Set(Self.thresholds + [policy.effectiveLargeThreshold])).sorted()
    }

    private var threshold: Binding<Int> {
        Binding(
            get: { policy.effectiveLargeThreshold },
            set: { value in
                var proposed = policy
                proposed.largeThreshold = value
                Task { await viewModel.request(proposed) }
            }
        )
    }

    private func changing<Value>(_ keyPath: WritableKeyPath<ClipStoragePolicy, Value>) -> Binding<Value> {
        Binding(
            get: { policy[keyPath: keyPath] },
            set: { value in
                var proposed = policy
                proposed[keyPath: keyPath] = value
                Task { await viewModel.request(proposed) }
            }
        )
    }

    private func bytes(_ count: Int) -> String {
        Int64(count).formatted(.byteCount(style: .file))
    }

    private func duration(_ interval: TimeInterval) -> String {
        Duration.seconds(interval).formatted(.units(allowed: [.days, .hours], width: .abbreviated))
    }

    private func title(of retention: ClipRetention) -> String {
        switch retention {
        case .oneDay: String(localized: "1 jour")
        case .oneWeek: String(localized: "1 semaine")
        case .oneMonth: String(localized: "1 mois")
        case .threeMonths: String(localized: "3 mois")
        case .sixMonths: String(localized: "6 mois")
        case .forever: String(localized: "Jamais")
        }
    }
}
