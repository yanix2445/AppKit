# Database

The data store: its type, the main entities, and the conventions. The macro model, not the full schema.

## Setup

- SwiftData ; le `ModelContainer` est créé dans `CopyKit/App/CopyKitApp.swift` et injecté avec `.modelContainer`.

## Main entities

- Seul existe le modèle d'exemple `Item` du template Xcode ; les vrais modèles arrivent avec la première story.

## Conventions

- Les modèles stockés (`@Model`) sont suffixés `…Record`, pour ne pas les confondre avec les `AppEntity` d'App Intents.
- Schéma versionné dès le premier vrai modèle (`VersionedSchema` + `SchemaMigrationPlan`) ; toute nouvelle propriété a une valeur par défaut.
- Chaque modèle a son propre `uid: UUID` : `persistentModelID` change au premier enregistrement.
- L'historique est chiffré : le contenu, les formats et le texte de recherche sont des blocs chiffrés ; seuls la date, la taille, la catégorie, l'état épinglé et l'état volumineux restent lisibles. Voir `aidd_docs/memory/internal/decisions/historique-chiffre-en-memoire.md`.
- Les vues ne lisent pas l'historique avec `@Query` : elles lisent un objet `@Observable` en mémoire, alimenté par `CopyKitData` hors du fil principal, avec un index de recherche contigu chargé à l'ouverture du bandeau et libéré à sa fermeture.
- Ailleurs, passer par `ModelContext` et `FetchDescriptor`.
- Tests et Previews sur un conteneur en mémoire, jamais sur les vraies données.
