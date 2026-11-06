# Codebase Map

The macro layout: the top-level areas and what each holds. A map to navigate, not the full tree.

```mermaid
flowchart TD
  Root["AppKit/ (dépôt)"] --> App["AppKit/ · cible app"]
  Root --> Tests["AppKitTests/ · Swift Testing"]
  Root --> UITests["AppKitUITests/ · XCUITest"]
  Root --> Aidd["aidd_docs/ · toute la documentation"]
```

## Areas

- `AppKit/`: la cible app ; `App/` (point d'entrée), `Resources/` (assets) ; `ContentView.swift` et `Item.swift` sont l'exemple du template Xcode, remplacés par la première story.
- `AppKitTests/`: tests unitaires et d'intégration Swift Testing.
- `AppKitUITests/`: tests d'interface XCUITest.
- `aidd_docs/`: toute la documentation : mémoire, décisions (`memory/internal/decisions/`), guide des plugins et du workflow (`memory/external/plugins-et-workflow/`), brief, backlog, plans.

## Entry points

- `AppKit/App/AppKitApp.swift` : `@main`, scène principale et conteneur SwiftData.
