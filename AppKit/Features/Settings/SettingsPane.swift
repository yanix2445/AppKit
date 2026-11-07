import Foundation
import SwiftUI

/// A page of the settings. Updates and About arrive with their own features.
enum SettingsPane: String, CaseIterable, Identifiable {
    case general, shortcuts, sounds, privacy, storage, permissions

    var id: Self { self }

    var title: String {
        switch self {
        case .general: String(localized: "Général")
        case .shortcuts: String(localized: "Raccourcis")
        case .sounds: String(localized: "Sons")
        case .privacy: String(localized: "Confidentialité")
        case .storage: String(localized: "Stockage")
        case .permissions: String(localized: "Permissions")
        }
    }

    var symbolName: String {
        switch self {
        case .general: "gearshape.fill"
        case .shortcuts: "keyboard.fill"
        case .sounds: "speaker.wave.2.fill"
        case .privacy: "lock.fill"
        case .storage: "externaldrive.fill"
        case .permissions: "checkmark.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .general: .gray
        case .shortcuts: .indigo
        case .sounds: .pink
        case .privacy: .green
        case .storage: .orange
        case .permissions: .purple
        }
    }
}
