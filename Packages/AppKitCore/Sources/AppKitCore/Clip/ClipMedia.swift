/// What the history keeps in memory about an image or a PDF. The data itself stays on disk.
public struct ClipMedia: Equatable, Codable, Sendable {
    public var byteCount: Int
    public var pixelWidth: Int?
    public var pixelHeight: Int?
    public var pageCount: Int?
    public var hasThumbnail: Bool
    /// Still being read, sealed and given a thumbnail.
    public var isProcessing: Bool

    public init(
        byteCount: Int,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil,
        pageCount: Int? = nil,
        hasThumbnail: Bool = false,
        isProcessing: Bool = false
    ) {
        self.byteCount = byteCount
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.pageCount = pageCount
        self.hasThumbnail = hasThumbnail
        self.isProcessing = isProcessing
    }
}
