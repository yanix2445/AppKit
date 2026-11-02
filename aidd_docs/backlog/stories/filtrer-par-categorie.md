---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/chercher-dans-mon-historique.md
order: 14
---

# Story: Filtrer par catégorie

**As** un utilisateur de Mac
**I want** n'afficher qu'une catégorie de copies
**So that** je retrouve plus vite une image, un lien ou un fichier

## Acceptance

- Le bandeau propose les catégories Texte, Texte enrichi, Lien, Image, Fichier(s), Couleur, PDF et Autre ; en choisir une n'affiche qu'elle (XCUITest)
- Un filtre se combine avec la recherche (Swift Testing)
- Une seule action revient à toutes les copies (XCUITest)
