import AppKitCore
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Previews images with ImageIO and PDFs with Core Graphics, without recompressing the originals.
public struct SystemClipThumbnailService: ClipThumbnailService {
    private static let maxPixelSize = 512
    private static let quality = 0.8

    public init() {}

    public func makeThumbnail(from formats: [ClipRepresentation]) async -> ClipThumbnail {
        if let pdf = formats.first(where: { $0.type == ClipClassifier.pdfType }) {
            return Self.thumbnail(ofPDF: pdf.data)
        }
        if let image = formats.first(where: { ClipClassifier.imageTypes.contains($0.type) }) {
            return Self.thumbnail(ofImage: image.data)
        }
        return ClipThumbnail(imageData: nil)
    }

    private static func thumbnail(ofImage data: Data) -> ClipThumbnail {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return ClipThumbnail(imageData: nil)
        }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        return ClipThumbnail(
            imageData: image.flatMap(encode),
            pixelWidth: properties?[kCGImagePropertyPixelWidth] as? Int,
            pixelHeight: properties?[kCGImagePropertyPixelHeight] as? Int
        )
    }

    private static func thumbnail(ofPDF data: Data) -> ClipThumbnail {
        guard let provider = CGDataProvider(data: data as CFData),
              let document = CGPDFDocument(provider)
        else { return ClipThumbnail(imageData: nil) }
        return ClipThumbnail(
            imageData: document.page(at: 1).flatMap(render),
            pageCount: document.numberOfPages
        )
    }

    private static func render(_ page: CGPDFPage) -> Data? {
        let box = page.getBoxRect(.cropBox)
        guard box.width > 0, box.height > 0 else { return nil }
        let scale = CGFloat(maxPixelSize) / max(box.width, box.height)
        let width = Int(box.width * scale)
        let height = Int(box.height * scale)
        guard let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else { return nil }
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -box.minX, y: -box.minY)
        context.drawPDFPage(page)
        return context.makeImage().flatMap(encode)
    }

    private static func encode(_ image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }
}
