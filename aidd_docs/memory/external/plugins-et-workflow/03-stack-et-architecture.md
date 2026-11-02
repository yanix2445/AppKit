# Stack 100 % Apple et principes d'architecture

← [Retour à l'index](README.md) · Ordre d'utilisation : [02-workflow-macos.md](02-workflow-macos.md)

Ce fichier fixe le **cadre** de CopyKit : uniquement des outils et des
frameworks **natifs Apple et Swift**, dans leurs dernières versions, et des
principes de conception clairs. Les décisions précises (fonctionnalités,
découpage final, modèles de données) se prennent plus tard avec les skills, et
chacune est tracée dans un ADR (`aidd_docs/memory/internal/decisions/`).

CopyKit est **ta propre application**, conçue de zéro.

---

## 1. La règle : natif Apple, rien d'autre

| Règle | Concrètement |
| --- | --- |
| **Zéro dépendance tierce** | aucun package Swift externe, aucun outil Homebrew dans la chaîne de build ou de test |
| **Outils Apple uniquement** | Xcode, `xcodebuild`, Swift Package Manager, Instruments / `xctrace`, `xcresulttool`, `swift-format`, DocC, Icon Composer, Accessibility Inspector, `notarytool` |
| **Frameworks Apple uniquement** | Swift, SwiftUI, SwiftData, Swift Testing, XCTest, AppKit, App Intents… (§4) |
| **Pas de scripts maison pour remplacer un outil Apple** | quand Xcode sait faire (compiler une icône, lancer des tests, capturer l'UI), on utilise Xcode |
| **Les plugins Claude servent de savoir et de méthode** | le plugin officiel Apple, les plugins Markdown de Paul Hudson (SwiftData, concurrence, Swift Testing), AIDD pour la méthode (§3) |

Seule exception tolérée : un fichier de configuration ou un petit script shell
qui **appelle uniquement des outils Apple** (par exemple une commande
`xcodebuild test` écrite une fois dans `CLAUDE.md`), pour que les agents
lancent toujours la même chose.

---

## 2. Versions : ce qu'il y a de plus récent

Vérifié le 2026-10-31 sur la machine et chez Apple :

| Outil | Version | Statut |
| --- | --- | --- |
| Xcode | **27.1** (27A9275, sorti le 15 octobre 2026) | dernière version stable ; 27.2 est en RC |
| Swift | **6.4** | livré avec Xcode 27.1 |
| SDK macOS | **27.0** | livré avec Xcode 27.1 |
| macOS de la machine | 27.0.1 | |
| Cible de l'app | `MACOSX_DEPLOYMENT_TARGET = 27.0` sur l'app et les tests | déjà au plus récent ; si la cible baisse un jour, protéger les APIs de macOS 27 par `if #available(macOS 27, *)` |

Outils présents dans Xcode 27.1 sur la machine : `swift-format`,
`xcresulttool`, `xctrace`, `notarytool`, `stapler`, `actool`, `ictool`,
`docc`, ainsi que les apps Instruments, Icon Composer, Accessibility
Inspector, FileMerge et Create ML. La commande `shortcuts` (app Raccourcis)
est dans `/usr/bin`.

Le projet Xcode actuel est déjà réglé de façon moderne :

| Réglage | Valeur | Ce que ça veut dire |
| --- | --- | --- |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` | tout est sur le main actor par défaut |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` | concurrence Swift 6 simplifiée |
| Tests | `import Testing` | Swift Testing déjà en place, plus une cible UI tests |
| Groupes de fichiers | `PBXFileSystemSynchronizedRootGroup` | un fichier créé sur le disque entre dans le projet tout seul |
| Signature | `Automatic`, équipe `63C823J34N` | certificat stable : macOS garde les permissions d'un build à l'autre |
| `ENABLE_HARDENED_RUNTIME` | `YES` | requis pour notariser |
| String Catalogs | activés | localisation moderne |
| `SWIFT_VERSION` | **`5.0`** | ⚠️ à passer en mode de langage **Swift 6** |
| `ENABLE_APP_SANDBOX` | **`YES`** | ⚠️ à décider au brief (§4) |

Sources : [notes de version Xcode 27.1](https://developer.apple.com/tutorials/data/documentation/xcode-release-notes/xcode-27_1-release-notes.md),
[Xcode 27.1 (27A9275)](https://developer.apple.com/news/releases/?id=01082024a),
[versions d'Xcode](https://developer.apple.com/es/support/xcode/).

> Point connu : un fil des forums Apple signale sur Xcode 27.1 une erreur
> SwiftUI « SDK is not supported by the compiler » quand deux toolchains
> cohabitent. Garder la toolchain d'Xcode sélectionnée (`xcode-select -p` →
> `/Applications/Xcode.app`). [Fil du forum](https://developer.apple.com/forums/thread/852653).

---

## 3. Qui fait foi, sur quoi

| Sujet | Référence |
| --- | --- |
| SwiftUI (bonnes pratiques, performance, nouveautés SDK 27) | skills Apple `swiftui-specialist`, `swiftui-whats-new-27` |
| Swift Testing | skill Apple `modernize-tests` + plugin `swift-testing-pro` (Paul Hudson) |
| App Intents (Raccourcis, Spotlight) | skills Apple `app-intents-specialist`, `app-intents-whats-new-27` |
| Accessibilité | skills Apple `accessibility-voiceover-specialist`, `accessibility-sufficient-contrast-specialist` + Accessibility Inspector |
| Traduction | skill Apple `translation-coordinator` (String Catalogs) |
| Sécurité du build | skill Apple `audit-xcode-security-settings` |
| Design et ergonomie macOS | [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) d'Apple + principes du §6 |
| SwiftData | plugin `swiftdata-pro` (Paul Hudson) + documentation Apple |
| Concurrence Swift 6 | plugin `swift-concurrency-pro` (Paul Hudson) + documentation Swift |
| AppKit, APIs système | [documentation Apple](https://developer.apple.com/documentation/) (consultable via le serveur MCP Xcode) ; incertitudes levées par un spike (`aidd-pm:05-spike`) |
| Architecture | principes du §5 + `aidd-dev:04-audit`, `aidd-dev:07-refactor`, facette architecture d'`aidd-dev:03-assert` |
| Méthode (cadrage, plan, revue, PR) | AIDD ([01](01-aidd-framework.md)) |

Les skills Apple sont détaillées dans [04-plugin-apple-xcode.md](04-plugin-apple-xcode.md).

### Comment on vérifie, avec les outils Apple

| Besoin | Outil natif |
| --- | --- |
| Compiler | Xcode ou `xcodebuild` (ou le serveur MCP `xcode`) |
| Voir l'interface, clair et sombre | **SwiftUI Previews** pendant le développement ; **XCUITest** qui ouvre chaque écran et joint une capture au résultat (`XCTAttachment`), lisible dans le rapport d'Xcode ou avec `xcresulttool` |
| Tester la logique | **Swift Testing**, sur un `ModelContainer` en mémoire |
| Tester l'app réelle | **XCUITest**, regroupé avec le reste dans un **Test Plan** (`.xctestplan`) |
| Exposer les actions de l'app | **App Intents**, appelables depuis Raccourcis, Spotlight et `shortcuts run` |
| Alignement | tokens d'espacement en Swift, conteneurs SwiftUI (`Form`, `Grid`, `LabeledContent`), **View Debugger** d'Xcode |
| Icône | **Icon Composer** ; Xcode compile le fichier `.icon` |
| Performance | **Instruments** / `xctrace`, mesures XCTest |

---

## 4. Les frameworks Apple à utiliser

### Le socle

| Framework | Rôle dans CopyKit | Règles |
| --- | --- | --- |
| **Swift 6.4**, mode de langage Swift 6 | langage, concurrence stricte | zéro warning ; `@concurrent nonisolated` pour le calcul lourd ; `actor` pour l'état partagé ; pas de `@unchecked Sendable` sans commentaire |
| **SwiftUI** | toute l'interface : fenêtres, `MenuBarExtra`, `Settings`, listes | composants système d'abord ; Liquid Glass seulement sur la couche de contrôle |
| **Observation** (`@Observable`) | état des écrans | `@State` pour posséder, `@Bindable` pour lier, `@ObservationIgnored` pour caches et timers |
| **SwiftData** | persistance locale | schéma versionné dès le début (`VersionedSchema` + `SchemaMigrationPlan`) ; valeur par défaut sur chaque nouvelle propriété ; un `uid: UUID` par modèle |
| **AppKit** | ce que SwiftUI ne couvre pas : `NSPanel`, `NSPasteboard`, `NSStatusItem`, `NSEvent` | via `NSViewRepresentable` / `NSHostingView` |
| **Swift Package Manager** (packages locaux dans le projet) | découper le code en modules (§5) | intégré à Xcode |
| **OSLog** (`Logger`) | journaux structurés, lisibles dans l'app Console | jamais de `print` ; jamais de contenu copié dans les logs |
| **String Catalogs** | textes et localisation | déjà activés |
| **DocC** | documentation du code des packages | intégré à Xcode |

### Tester et vérifier

| Outil Apple | Pour quoi |
| --- | --- |
| **Swift Testing** (`@Test`, `#expect`, `#require`, tests paramétrés) | tests unitaires et d'intégration : règles, données, modèles |
| **XCTest / XCUITest** | tests de l'interface de l'app réelle, captures d'écran jointes aux résultats, mesures (`XCTClockMetric`, `XCTMemoryMetric`, `XCTApplicationLaunchMetric`) |
| **Test Plans** (`.xctestplan`) | regrouper les tests, les configurations (clair / sombre, langues) et activer la couverture de code |
| `xcodebuild test` + `xcresulttool` | lancer les tests en ligne de commande (pour les agents) et lire le rapport |
| **SwiftUI Previews** (`#Preview`) | voir chaque vue en clair, en sombre et avec du contenu long pendant le développement |
| **Instruments** / `xctrace` | performance : Time Profiler, Hangs, Animation Hitches, Allocations, Leaks, Energy |
| **Accessibility Inspector** | audit d'accessibilité |
| **View Debugger** d'Xcode | inspecter la hiérarchie et l'alignement des vues |
| **`swift-format`** (dans la toolchain) | formatage et lint du code Swift |

### Les intégrations système (selon les besoins)

| Besoin probable | API Apple | Permission |
| --- | --- | --- |
| Surveiller le presse-papiers | AppKit `NSPasteboard.changeCount` | aucune |
| Raccourci global | Carbon `RegisterEventHotKey` (*) | aucune |
| Panneau rapide qui laisse l'autre app devant | AppKit `NSPanel` `.nonactivatingPanel` | aucune |
| Coller dans l'app au premier plan | `NSPasteboard` + Core Graphics `CGEvent` (⌘V) | **Accessibility** |
| Icône de menu bar | SwiftUI `MenuBarExtra` | aucune |
| Lancer à l'ouverture de session | **ServiceManagement** `SMAppService` | accord unique |
| Types de contenu, glisser-déposer | **UniformTypeIdentifiers**, **CoreTransferable** | aucune |
| Actions dans Raccourcis et Spotlight | **App Intents** | aucune |
| Secrets éventuels | **Security** (Keychain) | aucune |
| Texte dans les images copiées | **Vision** | aucune |
| IA sur l'appareil (optionnel) | **FoundationModels** | aucune |
| Astuces d'usage (optionnel) | **TipKit** | aucune |
| Rapports de performance et de crash en production | **MetricKit** + Organizer d'Xcode | aucune |

(*) Carbon est un framework Apple ancien mais toujours livré dans le SDK
macOS 27. C'est la seule API Apple pour un raccourci clavier global qui ne
demande aucune permission ; les raccourcis SwiftUI (`.keyboardShortcut`) ne
marchent que quand l'app est au premier plan.

Tous ces frameworks sont présents dans le SDK macOS 27 de la machine.

### La décision App Sandbox

Le sandbox est activé aujourd'hui. Si CopyKit doit **coller dans d'autres
apps**, il faut Accessibility + `CGEvent`, que le sandbox bloque. Il faudra
alors le désactiver et distribuer hors Mac App Store, en app signée
**Developer ID** et notarisée (`notarytool`, `stapler`). Si CopyKit se limite à
remplir le presse-papiers sans coller à ta place, le sandbox peut rester et le
Mac App Store reste possible. C'est une décision produit à prendre au brief,
puis à tracer dans un ADR.

---

## 5. Principes d'architecture

### 5.1 Des modules avec une seule direction de dépendance

Cible app Xcode **fine**, logique dans des **packages Swift locaux** ajoutés au
projet (testables seuls avec Swift Testing) :

```text
CopyKit (cible app Xcode)  : SwiftUI, scènes, menus, assemblage des dépendances
   │
   ├──> CopyKitFeatures   : un dossier par feature (vue + modèle @MainActor de la page)
   │        │
   ├──> CopyKitSystem     : adaptateurs macOS (presse-papiers, raccourci, collage, permissions)
   │        │
   ├──> CopyKitData       : persistance SwiftData derrière un protocole
   │        │
   └──────> CopyKitCore   : types du domaine, règles pures, aucune dépendance UI
```

- Les flèches vont **toujours vers le cœur**. `CopyKitCore` ne connaît ni
  SwiftUI, ni SwiftData, ni AppKit.
- La cible app est la **racine de composition** : le seul endroit qui crée les
  implémentations réelles et les injecte.
- ✅ Validé dans l'[ADR 0001](../../internal/decisions/architecture-mv-feature-core.md) ; arborescence et nommage dans [06](06-arborescence-et-nommage.md). On commence par `CopyKitCore` + la
  cible app, puis on découpe quand un signal le demande (5.7).

### 5.2 Des coutures avec deux implémentations

Un protocole seulement là où on échange un comportement : presse-papiers
système, horloge, stockage, raccourci global, collage. Chaque protocole a dès
le premier jour une implémentation réelle et une implémentation de test.

### 5.3 Les modifications passent par des opérations pures

Chaque changement de données est une opération (`enum` `Sendable`) appliquée à
une valeur. Un seul point d'entrée sert l'UI, l'Undo, les App Intents et les
tests.

### 5.4 L'état est séparé selon sa fréquence de mise à jour

Une valeur qui change souvent vit dans son propre petit objet observable. Le
main thread ne fait que de l'UI : I/O, décodage d'images et appels
Accessibility vont ailleurs. Objectifs : réponse en moins de 100 ms, aucun
blocage de plus de 50 ms, mesurés dans Instruments.

### 5.5 Les erreurs sont typées

Un `enum` d'erreur par module, conforme à `LocalizedError`. L'UI affiche un
message qui dit quoi faire. Le `fatalError` du template sur le
`ModelContainer` sera remplacé.

### 5.6 Confidentialité par construction

- Stockage local uniquement, aucun réseau sauf décision explicite.
- Les contenus marqués confidentiels par l'app d'origine ne sont pas gardés.
- Rien de copié dans les logs (`Logger` avec `privacy: .private`).
- Tests sur un `ModelContainer` en mémoire, jamais sur les vraies données.

### 5.7 Garder l'architecture saine

Signaux de bilan : fin de milestone, fichier de plus de 600 lignes, feature qui
touche plus de 6 fichiers, bug qui revient au même endroit. Refactor un pas
par commit, comportement prouvé identique par les tests. Décisions difficiles
à défaire → un ADR dans `aidd_docs/memory/internal/decisions/` ; leçon tirée d'un bug → `aidd-context:10-learn`.

Checklist de revue (`aidd-dev:checker`) : pas de duplication, pas
d'incohérence, pas de sur-ingénierie, pas de code mort ni de reste de debug.

---

## 6. Principes de design

| Principe | Comment |
| --- | --- |
| Natif d'abord | composants SwiftUI système, SF Symbols, styles de texte macOS (body 13 pt), une seule couleur d'accent, mode sombre vérifié |
| Tokens, jamais de valeurs brutes | couleurs, rayons, espacements et animations définis une fois en Swift ; `design/DESIGN-SYSTEM.md` dit quel token utiliser quand |
| Espacements réguliers | échelle de 4 pt en tokens Swift ; laisser `Form`, `Grid`, `LabeledContent` aligner |
| UX décidée avant le code | glossaire, flux, surface la plus légère, tous les états, textes, accessibilité (`aidd-refine:03-shadow-areas` pour traquer les états oubliés) |
| Clavier d'abord | chaque action fréquente a un raccourci et une entrée de menu |
| Fenêtres calmes | aucun focus à l'ouverture, sauf un champ de saisie dédié |
| Icône à toi | faite dans Icon Composer, une seule idée, pas de SF Symbol |
| Accessibilité | VoiceOver, clavier seul, Reduce Motion ; audit dans Accessibility Inspector |

---

## 7. Principes de système et de livraison

| Principe | Application |
| --- | --- |
| Jamais sur `main` | une branche `claude/*` par tâche, PR en draft (`aidd-vcs:02-pull-request`) |
| Commits atomiques | un sujet par commit, message conventionnel (`aidd-vcs:01-commit`) |
| « Fini » veut dire vérifié | build sans warning + Test Plan vert + captures XCUITest clair et sombre regardées |
| Un bug commence par un test qui échoue | `aidd-dev:08-debug` + Swift Testing |
| Revue indépendante avant merge | `aidd-dev:05-review` puis `aidd-refine:02-challenge` |
| Mémoire du projet à jour | `aidd-context:02-project-memory`, leçons via `aidd-context:10-learn` |
| Décisions tracées | ADR dans `aidd_docs/memory/internal/decisions/` (sandbox, persistance, modules) |
| Distribution | Archive Xcode → Developer ID → `notarytool` → `stapler` (ou Mac App Store si le sandbox reste) |
| Versions | semver, tag annoté et notes (`aidd-vcs:03-release-tag`) |
