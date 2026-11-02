---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/ouvrir-le-bandeau-au-raccourci-global.md
order: 6
---

# Story: Coller directement dans l'app active

**As** un utilisateur de Mac
**I want** qu'une copie choisie dans le bandeau soit collée directement là où j'écrivais
**So that** je n'aie pas à faire ⌘V moi-même

## Acceptance

- Avec la permission Accessibilité, choisir une copie ferme le bandeau et la colle dans l'app active, en 150 ms au plus (XCUITest et test de performance XCTest)
- Au premier collage direct, CopyKit explique : « Pour coller directement dans l'app que tu utilises, CopyKit a besoin de la permission Accessibilité. Sans elle, l'élément sera simplement copié et tu feras ⌘V. », avec Ouvrir les Réglages et Plus tard (XCUITest)
- Sans la permission, la copie est remise dans le presse-papiers et un petit message « Copié · fais ⌘V » propose « Activer le collage direct » (XCUITest)
- Une permission accordée plus tard est reconnue au retour depuis les Réglages Système, et le collage direct marche dès la fois suivante (essai manuel)
