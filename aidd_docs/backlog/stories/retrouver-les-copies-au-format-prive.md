---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 11
---

# Story: Retrouver les copies au format privé d'une app

**As** un utilisateur de Mac
**I want** retrouver les copies que seule leur app sait lire, comme un calque de Figma
**So that** je les recolle dans cette app exactement comme je les avais copiées

## Acceptance

- Une copie qui n'a qu'un format privé d'app est gardée avec tous ses formats et se recolle identique (Swift Testing)
- Elle s'affiche dans la catégorie Autre, avec l'icône de l'app source (XCUITest)
- Un élément copié dans Figma et dans Xcode se recolle dans la même app sans perte (essai manuel)
