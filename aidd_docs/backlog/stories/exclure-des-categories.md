---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/filtrer-par-categorie.md
order: 21
---

# Story: Exclure des catégories

**As** un utilisateur de Mac
**I want** choisir des catégories de copies qu'AppKit ne garde jamais
**So that** l'historique ne contienne que ce qui m'est utile

## Acceptance

- Les Réglages permettent d'exclure une ou plusieurs catégories, dans un menu à coches ; aucune n'est exclue par défaut (XCUITest)
- Une copie d'une catégorie exclue n'est jamais gardée, et son contenu n'est jamais écrit sur le disque (Swift Testing)
- Exclure une catégorie ne supprime pas les copies déjà gardées (Swift Testing)
