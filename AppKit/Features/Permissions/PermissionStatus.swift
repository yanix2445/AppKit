import Foundation

/// Where a permission stands, always said in words as well as in color.
enum PermissionStatus: Equatable {
    case granted, toGrant, denied

    var title: String {
        switch self {
        case .granted: String(localized: "Autorisée")
        case .toGrant: String(localized: "À autoriser")
        case .denied: String(localized: "Refusée")
        }
    }
}
