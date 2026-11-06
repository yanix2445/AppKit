import AppKit
import AppKitCore
import Foundation

/// Loads previews when the strip shows them, and frees them when it closes.
@MainActor
final class ClipThumbnailProvider {
    private let load: (Clip.ID) async -> Data?
    private var images: [Clip.ID: NSImage] = [:]

    init(load: @escaping (Clip.ID) async -> Data?) {
        self.load = load
    }

    func image(for id: Clip.ID) async -> NSImage? {
        if let image = images[id] { return image }
        guard let data = await load(id), let image = NSImage(data: data) else { return nil }
        images[id] = image
        return image
    }

    func releaseAll() {
        images.removeAll()
    }
}
