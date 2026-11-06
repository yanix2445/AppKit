import AppKit
import AppKitCore
import AppKitSystem
import CoreGraphics
import Testing

struct SystemClipThumbnailServiceTests {
    private func makePNG(width: Int, height: Int) throws -> Data {
        let bitmap = try #require(NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ))
        return try #require(bitmap.representation(using: .png, properties: [:]))
    }

    private func makePDF(pageCount: Int) throws -> Data {
        let data = NSMutableData()
        let consumer = try #require(CGDataConsumer(data: data))
        var box = CGRect(x: 0, y: 0, width: 200, height: 300)
        let context = try #require(CGContext(consumer: consumer, mediaBox: &box, nil))
        for _ in 0..<pageCount {
            context.beginPDFPage(nil)
            context.endPDFPage()
        }
        context.closePDF()
        return data as Data
    }

    @Test func anImageGetsAThumbnailAndItsSize() async throws {
        let formats = [ClipRepresentation(type: "public.png", data: try makePNG(width: 1000, height: 667))]
        let thumbnail = await SystemClipThumbnailService().makeThumbnail(from: formats)
        #expect(thumbnail.pixelWidth == 1000)
        #expect(thumbnail.pixelHeight == 667)
        let data = try #require(thumbnail.imageData)
        #expect(data.count < formats[0].data.count * 10)
        #expect(NSImage(data: data) != nil)
    }

    @Test func aPDFGetsAThumbnailAndItsPageCount() async throws {
        let formats = [ClipRepresentation(type: "com.adobe.pdf", data: try makePDF(pageCount: 2))]
        let thumbnail = await SystemClipThumbnailService().makeThumbnail(from: formats)
        #expect(thumbnail.pageCount == 2)
        #expect(thumbnail.imageData != nil)
    }

    @Test func aBrokenFileGetsNoThumbnailAndDoesNotFail() async {
        let formats = [ClipRepresentation(type: "public.png", data: Data([1, 2, 3]))]
        #expect(await SystemClipThumbnailService().makeThumbnail(from: formats).imageData == nil)
    }
}
