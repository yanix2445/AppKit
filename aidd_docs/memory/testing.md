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

- `AppKitTests/` reprend l'arborescence de `AppKit/Features/` ; un fichier `<Type>Tests.swift` par type testé.
- `AppKitUITests/` : un fichier `<Feature>UITests.swift` par feature.
- Les tests SwiftData utilisent un `ModelContainer` en mémoire, jamais les vraies données.
- Un bug corrigé commence par un test qui échoue.

## Performance

- Les budgets de sobriété et de réactivité se vérifient sur le Mac de référence de Yanis (Apple silicon, macOS 27). Les Mac de GitHub, des machines virtuelles aux performances variables, ne servent qu'à repérer les régressions.

## Definition of Done

Ce qui vaut pour toute story, en plus de ses propres critères :

- les tests unitaires et d'interface passent ;
- tout se fait au clavier, et chaque contrôle a un libellé VoiceOver ;
- l'interface est vérifiée en mode clair et en mode sombre ;
- chaque texte de l'interface est dans le String Catalog, en français (langue source) et en anglais ;
- aucune copie ni aucune clé n'est écrite en clair sur le disque ;
- les budgets de performance de la story tiennent sur le Mac de référence.

## Run

- Unitaires : `xcodebuild -project AppKit.xcodeproj -scheme AppKit -destination 'platform=macOS' test -only-testing:AppKitTests`
- Tout : `xcodebuild -project AppKit.xcodeproj -scheme AppKit -destination 'platform=macOS' test`
- Packages, que le schéma AppKit ne lance pas : `swift test --package-path Packages/AppKitCore` et `swift test --package-path Packages/AppKitSystem`
