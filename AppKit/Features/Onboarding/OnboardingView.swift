import AppKitCore
import SwiftUI

/// The five steps of the first launch: what AppKit does, and the few keys to know.
struct OnboardingView: View {
    let shortcuts: ShortcutsController
    let close: () -> Void

    @State private var step = OnboardingStep.welcome
    @AccessibilityFocusState private var isTitleFocused: Bool

    private var openHistory: HotKeyCombination? { shortcuts.current[.openHistory] }
    private var paste: HotKeyCombination? { shortcuts.current[.paste] }
    private var pin: HotKeyCombination? { shortcuts.current[.togglePin] }
    private var isLast: Bool { step == OnboardingStep.allCases.last }

    private var title: String {
        switch step {
        case .welcome: String(localized: "Bienvenue dans AppKit")
        case .reopen: String(localized: "Ouvrez l’historique, puis recollez")
        case .find: String(localized: "Retrouvez vos copies")
        case .pin: String(localized: "Gardez l’essentiel sous la main")
        case .ready: String(localized: "Tout est prêt")
        }
    }

    private var message: String {
        switch step {
        case .welcome:
            return String(localized: "AppKit garde ce que vous copiez et vous le rend en un instant. Il marche tout de suite, sans aucun réglage.")
        case .reopen:
            let reopen = openHistory?.displayName
            let choose = paste?.displayName ?? String(localized: "un clic")
            if let reopen {
                return String(localized: "Copiez comme d’habitude. \(reopen) ouvre le bandeau en bas de l’écran, et \(choose) reprend la copie sélectionnée.")
            }
            return String(localized: "Copiez comme d’habitude. L’icône de la barre de menus ouvre le bandeau en bas de l’écran, et \(choose) reprend la copie sélectionnée.")
        case .find:
            return String(localized: "Le bandeau ouvert, tapez simplement quelques mots, sans cliquer. Les accents et les majuscules ne comptent pas.")
        case .pin:
            if let pin {
                return String(localized: "Appuyez sur \(pin.displayName), ou faites un clic droit puis Épingler. La copie reste à gauche du bandeau et n’est jamais effacée.")
            }
            return String(localized: "Faites un clic droit puis Épingler. La copie reste à gauche du bandeau et n’est jamais effacée.")
        case .ready:
            return String(localized: "Copiez comme d’habitude, AppKit s’occupe du reste. Vous pouvez revoir cette découverte dans les Réglages.")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            OnboardingPictureView(step: step, openHistory: openHistory, paste: paste)
                .frame(height: OnboardingMetrics.pictureHeight)

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(verbatim: title)
                    .font(.title2.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($isTitleFocused)
                    .accessibilityIdentifier("onboarding.title")
                Text(verbatim: message)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("onboarding.message")
                Spacer(minLength: 0)
                footer
            }
            .padding(Spacing.xLarge)
        }
        .frame(width: OnboardingMetrics.width, height: OnboardingMetrics.height)
        .onChange(of: step) { isTitleFocused = true }
    }

    private var footer: some View {
        HStack(spacing: Spacing.small) {
            progress
            Spacer()
            if !isLast {
                Button("Passer", action: close)
                    .keyboardShortcut(.cancelAction)
                    .accessibilityIdentifier("onboarding.skip")
            }
            Button(isLast ? "Commencer" : "Continuer") {
                if let next = OnboardingStep(rawValue: step.rawValue + 1) {
                    step = next
                } else {
                    close()
                }
            }
            .keyboardShortcut(.defaultAction)
            .accessibilityIdentifier("onboarding.next")
        }
    }

    private var progress: some View {
        HStack(spacing: Spacing.xSmall) {
            ForEach(OnboardingStep.allCases, id: \.self) { item in
                Capsule()
                    .fill(item == step ? Color.accentColor : AppColor.controlFill)
                    .frame(width: item == step ? Spacing.large : Spacing.small, height: Spacing.small)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Étape \(step.rawValue + 1) sur \(OnboardingStep.allCases.count)"))
        .accessibilityIdentifier("onboarding.progress")
    }
}
