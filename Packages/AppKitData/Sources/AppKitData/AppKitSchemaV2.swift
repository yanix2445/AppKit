import Foundation
import SwiftData

/// Adds the formats and the thumbnail of images and PDFs.
public enum AppKitSchemaV2: VersionedSchema {
    public static let versionIdentifier = Schema.Version(2, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [ClipRecord.self]
    }

    /// A stored copy. Only what sorting and cleaning need stays readable.
    @Model
    public final class ClipRecord {
        #Unique<ClipRecord>([\.uid])
        #Index<ClipRecord>([\.capturedAt])

        public var uid: UUID = UUID()
        public var capturedAt: Date = Date.distantPast
        public var byteCount: Int = 0
        public var kind: String = ""
        public var isPinned: Bool = false
        public var isLarge: Bool = false
        @Attribute(.externalStorage) public var sealedPayload: Data = Data()
        @Attribute(.externalStorage) public var sealedSearchText: Data = Data()
        @Attribute(.externalStorage) public var sealedFormats: Data?
        @Attribute(.externalStorage) public var sealedThumbnail: Data?

        init(
            uid: UUID,
            capturedAt: Date,
            byteCount: Int,
            kind: String,
            sealedPayload: Data,
            sealedSearchText: Data,
            sealedFormats: Data?,
            sealedThumbnail: Data?
        ) {
            self.uid = uid
            self.capturedAt = capturedAt
            self.byteCount = byteCount
            self.kind = kind
            self.sealedPayload = sealedPayload
            self.sealedSearchText = sealedSearchText
            self.sealedFormats = sealedFormats
            self.sealedThumbnail = sealedThumbnail
        }
    }
}

public typealias ClipRecord = AppKitSchemaV2.ClipRecord
