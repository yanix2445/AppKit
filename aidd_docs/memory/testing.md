# Testing

How the project is tested: the layers, the tools, and the conventions. Where tests live and how to run them.

## Strategy

- Unitaire et intégration : la logique et les données, sans lancer l'app.
- Interface : quelques parcours de l'app réelle, et les captures clair et sombre jointes au rapport de tests.
- Recette manuelle avant chaque version, pour les critères marqués manuels.

## Tools

- Swift Testing (`@Test`, `#expect`, `#require`) pour tous les nouveaux tests unitaires et d'intégration.
- XCTest seulement pour XCUITest et les mesures de performance (`measure`), que Swift Testing ne couvre pas.

## Conventions

- `CopyKitTests/` reprend l'arborescence de `CopyKit/Features/` ; un fichier `<Type>Tests.swift` par type testé.
- `CopyKitUITests/` : un fichier `<Feature>UITests.swift` par feature.
- Les tests SwiftData utilisent un `ModelContainer` en mémoire, jamais les vraies données.
- Un bug corrigé commence par un test qui échoue.

## Run

- Unitaires : `xcodebuild -project CopyKit.xcodeproj -scheme CopyKit -destination 'platform=macOS' test -only-testing:CopyKitTests`
- Tout : `xcodebuild -project CopyKit.xcodeproj -scheme CopyKit -destination 'platform=macOS' test`
