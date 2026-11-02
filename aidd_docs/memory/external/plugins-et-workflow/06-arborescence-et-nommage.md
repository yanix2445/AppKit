# Arborescence des dossiers et règles de nommage

← [Retour à l'index](README.md) · Architecture : [05-architectures.md](05-architectures.md) · Principes : [03-stack-et-architecture.md](03-stack-et-architecture.md)

✅ **Validé le 2026-10-31** et tracé dans
[ADR 0001](../../internal/decisions/architecture-mv-feature-core.md). Elle applique l'architecture retenue : **MV à la manière d'Apple,
rangé par feature, avec un cœur métier isolé** (Clean Architecture légère).

> Les features citées (`History`, `QuickPanel`, `MenuBar`, `Settings`,
> `Permissions`) et les types (`Clip…`) sont des **exemples** pour montrer
> les règles. Les vraies features sortiront du brief et du backlog.

---

## 1. Règles générales

| Règle | Pourquoi |
| --- | --- |
| Noms en **anglais**, types en `UpperCamelCase`, propriétés et fonctions en `lowerCamelCase` | conventions officielles de Swift (*API Design Guidelines*) |
| **Un type par fichier**, et le fichier porte le nom du type : `HistoryView` → `HistoryView.swift` | on trouve tout fichier par le nom du type |
| Le **rôle est porté par un suffixe** : `HistoryView`, `HistoryViewModel`, `ClipRecord` | c'est la convention Swift ; on lit le rôle d'un coup d'œil |
| **Pas de préfixe de projet** sur les types (pas de `CKHistoryView`) | les modules Swift servent déjà d'espace de noms ; les préfixes viennent d'Objective-C |
| **Préfixe seulement pour distinguer des implémentations** d'un même protocole : `SystemPasteboardService` (la vraie), `FakePasteboardService` (pour les tests) | on voit tout de suite laquelle tourne |
| Extensions : `Type+Sujet.swift` (`Date+Relative.swift`) | convention Apple et Swift |
| Les **modules** portent le nom de l'app en préfixe : `CopyKitCore`, `CopyKitData`, `CopyKitSystem` | on sait à quelle app appartient un import |
| Dossiers au **pluriel** quand ils regroupent plusieurs choses du même genre (`Features/`, `Components/`), au **singulier** pour une feature (`History/`) | lecture naturelle |
| Une feature reste **à plat** tant qu'elle a moins de 7 fichiers environ ; au-delà, sous-dossiers `Views/` et `Models/` à l'intérieur | pas de dossiers vides par principe |

---

## 2. Les suffixes par rôle

| Suffixe | Rôle | Couche | Exemple |
| --- | --- | --- | --- |
| `…App` | point d'entrée `@main` | app | `CopyKitApp` |
| `…View` | écran ou section d'écran SwiftUI | feature | `HistoryView`, `GeneralSettingsView` |
| `…Row` | ligne d'une liste | feature | `HistoryRow` |
| `…ViewModel` | objet `@Observable` qui porte la logique d'un écran, **seulement si nécessaire** | feature | `QuickPanelViewModel` |
| `…Style` | style de contrôle SwiftUI (`ButtonStyle`, `ToggleStyle`…) | shared | `ToolbarButtonStyle` |
| `…Record` | modèle stocké SwiftData (`@Model`) | data | `ClipRecord` |
| `…SchemaV1`, `…MigrationPlan` | versions du schéma SwiftData et migrations | data | `CopyKitSchemaV1`, `CopyKitMigrationPlan` |
| *(sans suffixe)* | type métier pur (struct, enum) | core | `ClipContent`, `ClipKind` |
| `…Policy` | règle de décision pure | core | `ClipRetentionPolicy` (combien garder, quoi ignorer) |
| `…Matcher`, `…Formatter`, `…Parser` | calcul pur sur des données | core | `ClipMatcher` (recherche) |
| `…Service` | **protocole** d'accès au système ou au stockage | system / data | `PasteboardService`, `HotKeyService` |
| `System…Service` | implémentation réelle sur macOS | system | `SystemPasteboardService` |
| `Fake…Service` | implémentation de test, contrôlable | testing | `FakePasteboardService` |
| `…Error` | `enum` d'erreurs d'un module, conforme à `LocalizedError` | toutes | `PasteboardError` |
| `…Intent`, `…Entity`, `…Shortcuts` | App Intents (Raccourcis, Spotlight) | app | `CopyClipIntent`, `ClipEntity`, `CopyKitShortcuts` |
| `…Tests` | tests Swift Testing d'un type | tests | `ClipMatcherTests` |
| `…UITests` | tests d'interface XCUITest d'une feature | tests | `HistoryUITests` |

Pourquoi `Record` pour SwiftData et pas `Entity` : App Intents utilise déjà le
mot *entity* (`AppEntity`). `ClipRecord` (stocké) et `ClipEntity` (exposé à
Raccourcis) ne se confondent jamais.

---

## 3. L'arborescence complète du dépôt

```text
CopyKit/                                   racine du dépôt git
├── CopyKit.xcodeproj
├── CLAUDE.md                              commandes de build et de test, règles pour les agents
│
├── CopyKit/                               CIBLE APP (dossier synchronisé Xcode)
│   ├── App/                               démarrage et assemblage
│   │   ├── CopyKitApp.swift               @main : scènes (fenêtre, MenuBarExtra, Settings)
│   │   ├── AppDependencies.swift          crée les services réels, une seule fois
│   │   └── EnvironmentValues+Dependencies.swift   expose les services via @Entry
│   │
│   ├── Features/                          UN DOSSIER PAR FONCTIONNALITÉ
│   │   ├── History/
│   │   │   ├── HistoryView.swift          liste lue avec @Query (MV pur)
│   │   │   └── HistoryRow.swift
│   │   ├── QuickPanel/
│   │   │   ├── QuickPanelView.swift
│   │   │   ├── QuickPanelViewModel.swift  ici il y a de la logique : recherche, sélection, collage
│   │   │   └── QuickPanelController.swift pont AppKit (NSPanel) si nécessaire
│   │   ├── MenuBar/
│   │   │   └── MenuBarView.swift
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift         onglets
│   │   │   ├── GeneralSettingsView.swift
│   │   │   └── ShortcutSettingsView.swift
│   │   └── Permissions/
│   │       └── PermissionsView.swift
│   │
│   ├── Intents/                           App Intents (Raccourcis, Spotlight)
│   │   ├── CopyClipIntent.swift
│   │   ├── ClipEntity.swift
│   │   └── CopyKitShortcuts.swift
│   │
│   ├── Shared/                            ce que plusieurs features réutilisent
│   │   ├── Components/                    petites vues génériques
│   │   │   └── EmptyStateView.swift
│   │   ├── Design/                        tokens de design (jamais de valeurs en dur ailleurs)
│   │   │   ├── Spacing.swift
│   │   │   ├── CornerRadius.swift
│   │   │   ├── AppColor.swift
│   │   │   ├── Motion.swift
│   │   │   └── ToolbarButtonStyle.swift
│   │   └── Extensions/
│   │       └── Date+Relative.swift
│   │
│   └── Resources/                         tout ce qui n'est pas du code
│       ├── Assets.xcassets
│       ├── AppIcon.icon                   icône Icon Composer
│       └── Localizable.xcstrings          String Catalog
│
├── Packages/                              MODULES SWIFT LOCAUX (le cœur isolé)
│   ├── CopyKitCore/                       métier pur : aucune dépendance à SwiftUI, SwiftData, AppKit
│   │   ├── Package.swift
│   │   ├── Sources/CopyKitCore/
│   │   │   └── Clip/
│   │   │       ├── ClipContent.swift
│   │   │       ├── ClipKind.swift
│   │   │       ├── ClipMatcher.swift
│   │   │       └── ClipRetentionPolicy.swift
│   │   └── Tests/CopyKitCoreTests/
│   │       ├── ClipMatcherTests.swift
│   │       └── ClipRetentionPolicyTests.swift
│   │
│   ├── CopyKitData/                       stockage SwiftData ; dépend de CopyKitCore
│   │   ├── Package.swift
│   │   ├── Sources/CopyKitData/
│   │   │   ├── ClipRecord.swift
│   │   │   ├── CopyKitSchemaV1.swift
│   │   │   ├── CopyKitMigrationPlan.swift
│   │   │   └── ModelContainer+CopyKit.swift   création du conteneur (réel ou en mémoire)
│   │   └── Tests/CopyKitDataTests/
│   │       └── ClipRecordTests.swift
│   │
│   └── CopyKitSystem/                     accès à macOS derrière des protocoles ; dépend de CopyKitCore
│       ├── Package.swift
│       ├── Sources/CopyKitSystem/
│       │   ├── Pasteboard/
│       │   │   ├── PasteboardService.swift          protocole
│       │   │   ├── SystemPasteboardService.swift    vraie implémentation (NSPasteboard)
│       │   │   └── PasteboardError.swift
│       │   ├── HotKey/
│       │   │   ├── HotKeyService.swift
│       │   │   └── SystemHotKeyService.swift        Carbon RegisterEventHotKey
│       │   └── Permissions/
│       │       ├── PermissionService.swift
│       │       └── SystemPermissionService.swift    Accessibility
│       ├── Sources/CopyKitSystemTesting/            implémentations de test, partagées par tous les tests
│       │   ├── FakePasteboardService.swift
│       │   ├── FakeHotKeyService.swift
│       │   └── FakePermissionService.swift
│       └── Tests/CopyKitSystemTests/
│           └── SystemPasteboardServiceTests.swift
│
├── CopyKitTests/                          TESTS SWIFT TESTING DE LA CIBLE APP (miroir de Features/)
│   └── Features/
│       └── QuickPanel/
│           └── QuickPanelViewModelTests.swift
│
├── CopyKitUITests/                        TESTS XCUITEST (un fichier par feature)
│   ├── HistoryUITests.swift
│   └── QuickPanelUITests.swift
│
├── TestPlans/
│   └── CopyKit.xctestplan                 unitaires + UI, clair et sombre, couverture
│
└── aidd_docs/                             TOUTE la documentation du projet (dossier synchronisé, sans cible)
    ├── README.md · GUIDELINES.md · CONTRIBUTING.md
    ├── memory/                            mémoire projet, chargée à chaque session
    │   ├── *.md                           architecture, design, navigation, vcs…
    │   ├── internal/decisions/            décisions d'architecture (ADR)
    │   └── external/plugins-et-workflow/  cette documentation, lue à la demande
    ├── product/                           Product Brief
    ├── backlog/                           epics, stories, spikes, defects, tasks
    └── tasks/                             brainstorms, plans, revues, audits
```

Il n'y a plus de dossier `docs/` : tout vit dans `aidd_docs/`, aux places
prévues par AIDD. Détail des chemins :
[07-catalogue-skills-aidd.md](07-catalogue-skills-aidd.md#où-aidd-range-ses-fichiers).

---

## 4. Qui a le droit d'importer quoi

| Couche | Peut importer | Ne doit jamais importer |
| --- | --- | --- |
| `CopyKitCore` | Foundation | SwiftUI, SwiftData, AppKit, les autres packages |
| `CopyKitData` | `CopyKitCore`, SwiftData | SwiftUI, AppKit, `CopyKitSystem` |
| `CopyKitSystem` | `CopyKitCore`, AppKit, Carbon, ServiceManagement | SwiftUI, SwiftData, `CopyKitData` |
| Cible app (`Features/`, `App/`, `Intents/`) | tout ce qui précède, SwiftUI, App Intents | — |
| Une feature | `Shared/`, les packages | **une autre feature** (on passe par `Shared/` ou un package) |

Le compilateur fait respecter les trois premières lignes tout seul, grâce aux
dépendances déclarées dans chaque `Package.swift`. La dernière est une règle de
revue (`aidd-dev:05-review`).

---

## 5. Ce qui change par rapport au template actuel

| Aujourd'hui | Plus tard |
| --- | --- |
| `CopyKit/CopyKitApp.swift` | `CopyKit/App/CopyKitApp.swift` |
| `CopyKit/ContentView.swift` | remplacé par les vues des features |
| `CopyKit/Item.swift` (modèle d'exemple) | remplacé par `Packages/CopyKitData/…/ClipRecord.swift` |
| `CopyKit/Assets.xcassets` | `CopyKit/Resources/Assets.xcassets` |

Comme `CopyKit/`, `CopyKitTests/` et `CopyKitUITests/` sont des dossiers
synchronisés, Xcode prend les sous-dossiers en compte tout seul. Les packages
locaux s'ajoutent une fois au projet, puis à la cible app.

`App/` et `Resources/` sont déjà en place. `Features/`, `Shared/`, `Intents/`
et `Packages/` arriveront avec la première story, à l'étape E du
[workflow](02-workflow-macos.md).
