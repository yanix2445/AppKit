# CopyKit

Application macOS native, 100 % Apple : Xcode 27.1, Swift 6.4 (mode de langage
Swift 6), SwiftUI, SwiftData, Swift Testing, XCUITest. Cible macOS 27.0.

## Règles

- **Zéro dépendance tierce** : aucun package Swift externe, aucun outil tiers
  dans le build ou les tests. Demander avant toute exception.
- **Architecture** : MV à la manière d'Apple, rangé par feature, cœur métier
  isolé dans des packages Swift locaux. Voir
  [la décision d'architecture](aidd_docs/memory/internal/decisions/architecture-mv-feature-core.md) et
  [l'arborescence et le nommage](aidd_docs/memory/external/plugins-et-workflow/06-arborescence-et-nommage.md).
- **Nommage** : un type par fichier, le fichier porte le nom du type, le rôle
  est donné par un suffixe (`…View`, `…Row`, `…ViewModel`, `…Record`,
  `…Policy`, `…Service`, `…Error`…). Préfixes `System…` / `Fake…` seulement
  pour l'implémentation réelle / de test d'un protocole.
- **Pas de dossier ni de package vide** : on les crée avec leur premier fichier.
- **Skills de référence** : les skills Apple `xcode-integration:*` font foi
  (SwiftUI, Swift Testing, App Intents, accessibilité, traduction). En cas de
  désaccord entre deux sources, Apple a raison.
- **Réglages du projet** : passer par les outils MCP Xcode
  (`UpdateTargetBuildSetting`, `AddEntitlement`, `AddInfoPlist`…), ne pas
  éditer `project.pbxproj` à la main. Seule exception : référencer un dossier
  ou un fichier racine (règle suivante), qu'aucun outil MCP ne sait faire.
- **Tout doit être visible dans Xcode** :
  - `CopyKit/`, `CopyKitTests/`, `CopyKitUITests/` et `aidd_docs/` sont des
    dossiers synchronisés : tout ce qui est créé dedans apparaît tout seul ;
  - un **nouveau dossier à la racine** du dépôt est déclaré, dès sa création,
    comme dossier synchronisé (`PBXFileSystemSynchronizedRootGroup`) **sans
    cible** dans le groupe principal ;
  - un **nouveau fichier à la racine** est ajouté comme simple référence
    (`PBXFileReference`) sans cible ;
  - un package local dans `Packages/` apparaît quand on le relie au projet ;
  - après chaque modification, vérifier avec `plutil -lint` et un build.

## Commandes

Les builds et les tests passent par Portly (`portly temp` puis `portly wait`).

```bash
# Build
xcodebuild -project CopyKit.xcodeproj -scheme CopyKit -destination 'platform=macOS' build

# Tests unitaires (Swift Testing)
xcodebuild -project CopyKit.xcodeproj -scheme CopyKit -destination 'platform=macOS' test -only-testing:CopyKitTests

# Tous les tests, y compris l'interface (XCUITest)
xcodebuild -project CopyKit.xcodeproj -scheme CopyKit -destination 'platform=macOS' test
```

Quand Xcode est ouvert, les outils MCP Xcode (`BuildProject`, `RunAllTests`,
`RunSomeTests`, `RenderPreview`, `GetBuildLog`) font la même chose depuis
l'IDE.

## Arborescence actuelle

```text
CopyKit/
  App/CopyKitApp.swift      point d'entrée
  Resources/Assets.xcassets
  ContentView.swift         modèle du template, à remplacer par la première feature
  Item.swift                modèle du template, à remplacer par la première feature
CopyKitTests/               tests Swift Testing
CopyKitUITests/             tests XCUITest
aidd_docs/                  toute la documentation (dossier synchronisé, sans cible)
```

`Features/`, `Shared/`, `Intents/` et `Packages/` apparaîtront avec leur premier
fichier.

## Documentation

- [aidd_docs/memory/external/plugins-et-workflow/](aidd_docs/memory/external/plugins-et-workflow/README.md) : plugins, stack, workflow, architecture.
- [aidd_docs/memory/internal/decisions/](aidd_docs/memory/internal/decisions/) : décisions d'architecture.

## Memory Management

Project docs, memory, specs, and plans live in `aidd_docs/`.

Read only task-relevant context and linked memory files; complete required reads.

<!-- aidd_project_memory:start -->

@aidd_docs/memory/architecture.md
@aidd_docs/memory/backlog.md
@aidd_docs/memory/codebase-map.md
@aidd_docs/memory/coding-assertions.md
@aidd_docs/memory/database.md
@aidd_docs/memory/design.md
@aidd_docs/memory/desktop.md
@aidd_docs/memory/ecosystem.md
@aidd_docs/memory/forms.md
@aidd_docs/memory/navigation.md
@aidd_docs/memory/project-brief.md
@aidd_docs/memory/testing.md
@aidd_docs/memory/vcs.md

<!-- read on demand, not auto-loaded -->
- aidd_docs/memory/internal/decisions/architecture-mv-feature-core.md
- aidd_docs/memory/external/plugins-et-workflow/01-aidd-framework.md
- aidd_docs/memory/external/plugins-et-workflow/02-workflow-macos.md
- aidd_docs/memory/external/plugins-et-workflow/03-stack-et-architecture.md
- aidd_docs/memory/external/plugins-et-workflow/04-plugin-apple-xcode.md
- aidd_docs/memory/external/plugins-et-workflow/05-architectures.md
- aidd_docs/memory/external/plugins-et-workflow/06-arborescence-et-nommage.md
- aidd_docs/memory/external/plugins-et-workflow/07-catalogue-skills-aidd.md

<!-- aidd_project_memory:end -->

- Load `aidd_docs/memory/external/*` only when asked.
- Load `aidd_docs/memory/internal/*` when relevant.
