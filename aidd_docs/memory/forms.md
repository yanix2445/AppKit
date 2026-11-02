# Forms

How forms are built and validated across the UI.

## Approach

- SwiftUI natif : `Form` avec `.formStyle(.grouped)`, `LabeledContent` et `Grid` pour aligner ; aucune bibliothèque de formulaire.

## Conventions

- Une erreur s'affiche à côté du champ concerné et dit comment la corriger.
- Return valide, Escape annule ; le bouton de confirmation nomme l'action.
