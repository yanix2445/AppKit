# Architecture MV par feature avec un cœur isolé

- Date: 2026-10-31
- Status: Accepted

## Context

CopyKit est une application macOS native, conçue de zéro, avec uniquement des
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
   directement les modèles `@Observable`, l'environnement et `@Query`. Un
   objet `@Observable` suffixé `…ViewModel` n'est créé que pour un écran qui
   porte de l'état ou de la logique propre. Ce n'est pas systématique.
2. **Organisation : par feature.** Un dossier par fonctionnalité dans
   `CopyKit/Features/`. Ce qui est partagé va dans `CopyKit/Shared/`.
3. **Modularisation : Clean Architecture légère**, avec trois packages Swift
   locaux dans `Packages/`, dont les dépendances vont toujours vers le cœur :
   - `CopyKitCore` : types et règles métier purs, sans SwiftUI, SwiftData ni
     AppKit ;
   - `CopyKitData` : stockage SwiftData, dépend de `CopyKitCore` ;
   - `CopyKitSystem` : accès à macOS derrière des protocoles, dépend de
     `CopyKitCore`. Les implémentations de test sont dans la cible
     `CopyKitSystemTesting`.
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
`Resources/`, plus `CopyKitCore`. `CopyKitData` et `CopyKitSystem` arrivent
avec la première fonctionnalité qui en a besoin. On ne crée jamais de dossier
ou de package vide.
