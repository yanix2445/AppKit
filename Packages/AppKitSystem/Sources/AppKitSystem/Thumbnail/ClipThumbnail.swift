import Foundation

/// A small preview of an image or a PDF, with what can be read from the original.
public struct ClipThumbnail: Equatable, Sendable {
    public let imageData: Data?
    public let pixelWidth: Int?
    public let pixelHeight: Int?
    public let pageCount: Int?

    public init(imageData: Data?, pixelWidth: Int? = nil, pixelHeight: Int? = nil, pageCount: Int? = nil) {
        self.imageData = imageData
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.pageCount = pageCount
    }
}
