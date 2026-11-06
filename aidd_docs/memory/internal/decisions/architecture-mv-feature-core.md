# Architecture MV par feature avec un cœur isolé

- Date: 2026-10-31
- Status: Accepted
- Superseded by: aidd_docs/memory/internal/decisions/historique-chiffre-en-memoire.md (partie stockage seulement)

## Context

AppKit est une application macOS native, conçue de zéro, avec uniquement des
outils et des frameworks Apple : Xcode 27.1, Swift 6.4, SwiftUI, SwiftData,
Swift Testing, XCUITest, et aucune dépendance tierce.

Apple n'impose pas d'architecture. Sa documentation et son skill officiel
`swiftui-specialist` décrivent en revanche le flux de données attendu :
`@State` pour l'état local d'une vue, des modèles `@Observable` partagés par
l'environnement, `Binding`, et `@Query` pour lire SwiftData dans les vues.

On veut :

- des rôles clairement séparés et lisibles dans les noms ;
- un code métier testable sans lancer l'app ;
- pouvoir ajouter, modifier ou supprimer une fonctionnalité à un seul endroit ;
- rester simple pour une application de cette taille.

## Decision

1. **Pattern de présentation : MV, à la manière d'Apple.** Les vues lisent
   directement les modèles `@Observable` et l'environnement. L'historique,
   chiffré, n'est pas lu avec `@Query` mais depuis un objet `@Observable` en
   mémoire ([ADR historique chiffré](historique-chiffre-en-memoire.md)). Un
   objet `@Observable` suffixé `…ViewModel` n'est créé que pour un écran qui
   porte de l'état ou de la logique propre. Ce n'est pas systématique.
2. **Organisation : par feature.** Un dossier par fonctionnalité dans
   `AppKit/Features/`. Ce qui est partagé va dans `AppKit/Shared/`.
3. **Modularisation : Clean Architecture légère**, avec trois packages Swift
   locaux dans `Packages/`, dont les dépendances vont toujours vers le cœur :
   - `AppKitCore` : types et règles métier purs, sans SwiftUI, SwiftData ni
     framework AppKit ;
   - `AppKitData` : stockage chiffré (SwiftData, CryptoKit et l'index de
     recherche), dépend de `AppKitCore` ;
   - `AppKitSystem` : accès à macOS derrière des protocoles, dépend de
     `AppKitCore`. Les implémentations de test sont dans la cible
     `AppKitSystemTesting`.
4. **La cible app est la racine de composition.** Elle crée les services réels
   dans `App/AppDependencies.swift` et les distribue par l'environnement.
5. **Nommage.** En anglais, un type par fichier, et le fichier porte le nom du
   type. Le rôle est donné par un suffixe (`…View`, `…Row`, `…ViewModel`,
   `…Record`, `…Policy`, `…Service`, `…Error`, `…Intent`, `…Entity`,
   `…Tests`, `…UITests`). Pas de préfixe de projet. Les préfixes `System…` et
   `Fake…` distinguent l'implémentation réelle de celle des tests.
6. **Règles d'import.**
   - Le compilateur impose celles entre packages, via les dépendances de
     chaque `Package.swift`.
   - Une feature n'importe jamais une autre feature : c'est vérifié en revue.
7. **Forme de l'app.** Une app de barre de menus, sans fenêtre principale ni
   icône dans le Dock : un `NSStatusItem`, car un clic doit ouvrir le bandeau et `MenuBarExtra` ne sait qu'ouvrir un menu ou une fenêtre, et `Settings` en SwiftUI. Le bandeau de
   l'historique est un `NSPanel` non activant, piloté depuis la feature
   `HistoryStrip`, qui glisse depuis le bas de l'écran et reçoit le clavier
   sans prendre le focus de l'app où l'on écrivait, condition du collage
   direct.
8. **Concurrence.** L'app est en `MainActor` par défaut. La capture,
   l'empreinte, le chiffrement, l'index de recherche et la lecture des copies
   venues d'un autre appareil tournent hors du fil principal.
9. **Dépendance tierce et synchronisation.** Sparkle vit dans la seule cible
   app, derrière un `UpdateService`, pour pouvoir y désactiver
   l'authentification des pointeurs sans toucher au reste. La synchronisation
   de la tranche 1.2 (`CKSyncEngine`) ira dans un package `AppKitSync`, créé
   avec elle.

L'arborescence complète, le tableau des suffixes et le tableau des imports
font foi dans [06-arborescence-et-nommage.md](../../external/plugins-et-workflow/06-arborescence-et-nommage.md).

## Alternatives

| Alternative | Raison |
| --- | --- |
| MVVM systématique | Beaucoup de ViewModels qui ne font que relayer. Friction avec SwiftData, dont `@Query` ne fonctionne que dans une vue |
| MVC | SwiftUI n'a pas de contrôleur |
| TCA / Redux | TCA est une bibliothèque tierce, exclue ; trop de cérémonie |
| VIPER | Beaucoup trop de fichiers pour une app de cette taille |
| Clean Architecture complète (use cases, repositories partout) | Trop lourde ; on n'en garde que la règle de dépendance et les protocoles |
| Rangement par couche (`Models/`, `Views/`, `ViewModels/`) | Une modification touche plusieurs dossiers à la fois |

## Consequences

- ✅ Le métier se teste en isolation avec Swift Testing, et le système se
  remplace par des `Fake…` dans les tests.
- ✅ Une fonctionnalité vit dans un seul dossier.
- ✅ Le compilateur empêche les mauvaises dépendances entre couches.
- ⚠️ Il faut ajouter les packages locaux au projet Xcode et maintenir leurs
  `Package.swift`.
- ⚠️ Il faut juger, écran par écran, si un `…ViewModel` est justifié. Ce point
  est contrôlé en revue (`aidd-dev:05-review`).
- Les fichiers du template Xcode `ContentView.swift` et `Item.swift` seront
  remplacés par la première story (étape E du workflow). `Assets.xcassets`
  est déjà déplacé dans `Resources/`.

**On commence petit.** On ne crée d'abord que la cible app avec `App/`, `Features/`, `Shared/` et
`Resources/`, plus `AppKitCore`. `AppKitData` et `AppKitSystem` arrivent
avec la première fonctionnalité qui en a besoin. On ne crée jamais de dossier
ou de package vide.
