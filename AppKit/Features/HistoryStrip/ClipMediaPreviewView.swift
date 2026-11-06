import AppKit
import AppKitCore
import SwiftUI

/// The preview of an image or a PDF. A copy that takes long to process shows an icon and a ring.
struct ClipMediaPreviewView: View {
    let id: Clip.ID
    let media: ClipMedia
    let symbolName: String
    /// An image fills its frame; a page stays whole.
    let contentMode: ContentMode
    let thumbnailProvider: ClipThumbnailProvider

    @State private var image: NSImage?
    @State private var showsProgress = false

    var body: some View {
        ZStack {
            if let image {
                // In an overlay, so that the picture never pushes the rest of the card aside.
                Color.clear
                    .overlay {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    }
                    .clipped()
                    .accessibilityIdentifier("history.card.thumbnail")
            } else {
                VStack(spacing: Spacing.small) {
                    Image(systemName: symbolName)
                        .font(.title)
                        .foregroundStyle(.secondary)
                    if showsProgress {
                        ProgressView()
                            .controlSize(.small)
                            .accessibilityIdentifier("history.card.progress")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: media.hasThumbnail) {
            guard media.hasThumbnail else { return }
            image = await thumbnailProvider.image(for: id)
        }
        .task(id: media.isProcessing) {
            showsProgress = false
            guard media.isProcessing else { return }
            try? await Task.sleep(for: Motion.processingIndicatorDelay)
            showsProgress = !Task.isCancelled
        }
    }
}
