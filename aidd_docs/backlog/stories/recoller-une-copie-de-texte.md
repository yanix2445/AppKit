---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/voir-mes-dernieres-copies-de-texte.md
order: 2
---

# Story: Recoller une copie de texte

**As** un utilisateur de Mac
**I want** choisir une copie dans le bandeau pour la remettre dans le presse-papiers
**So that** je la recolle où je veux avec ⌘V

## Acceptance

- Un clic ou la touche Entrée sur une copie met exactement ce texte dans le presse-papiers, ferme le bandeau et affiche « Copié · faites ⌘V » (Swift Testing et XCUITest)
- Les flèches gauche et droite parcourent les copies du bandeau, Entrée choisit, Échap ferme (XCUITest)
- Une copie remise par AppKit remonte en tête de l'historique sans créer de seconde entrée (Swift Testing)
