import SwiftData

public enum AppKitMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [AppKitSchemaV1.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}
