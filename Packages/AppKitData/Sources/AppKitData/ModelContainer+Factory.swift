import Foundation
import SwiftData

extension ModelContainer {
    /// The container of the history, in the given file.
    public static func history(at url: URL) throws -> ModelContainer {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        return try make(ModelConfiguration(url: url))
    }

    /// A container that writes nothing to disk, for tests and previews.
    public static func inMemoryHistory() throws -> ModelContainer {
        try make(ModelConfiguration(isStoredInMemoryOnly: true))
    }

    private static func make(_ configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: AppKitSchemaV1.self),
            migrationPlan: AppKitMigrationPlan.self,
            configurations: configuration
        )
    }
}
