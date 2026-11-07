import AppKitCore
import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// A pinned copy being moved in its section. Its private type goes nowhere else: dropped in
/// another app, it does nothing.
struct PinnedClipDrag: Codable, Transferable {
    static let contentType = UTType(exportedAs: "yanis-harrat.AppKit.pinned-clip")

    let id: Clip.ID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: contentType)
    }
}
