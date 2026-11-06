import Foundation
import SwiftData

public enum AppKitSchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

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

        init(
            uid: UUID,
            capturedAt: Date,
            byteCount: Int,
            kind: String,
            sealedPayload: Data,
            sealedSearchText: Data
        ) {
            self.uid = uid
            self.capturedAt = capturedAt
            self.byteCount = byteCount
            self.kind = kind
            self.sealedPayload = sealedPayload
            self.sealedSearchText = sealedSearchText
        }
    }
}

public typealias ClipRecord = AppKitSchemaV1.ClipRecord
