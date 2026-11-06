import SwiftData

public enum AppKitMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [AppKitSchemaV1.self, AppKitSchemaV2.self]
    }

    public static var stages: [MigrationStage] {
        [.lightweight(fromVersion: AppKitSchemaV1.self, toVersion: AppKitSchemaV2.self)]
    }
}
