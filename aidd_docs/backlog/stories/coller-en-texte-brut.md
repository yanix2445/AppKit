---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/coller-directement-dans-l-app-active.md
order: 7
---

# Story: Coller en texte brut

**As** un utilisateur de Mac
**I want** recoller une copie sans sa mise en forme
**So that** le texte prenne le style de l'endroit où je le colle

## Acceptance

- ⇧Entrée sur une copie la colle en texte brut, sans police, couleur ni lien (Swift Testing et XCUITest)
- Sans la permission Accessibilité, ⇧Entrée met le texte brut dans le presse-papiers et affiche « Copié · fais ⌘V » (XCUITest)
- Le menu contextuel d'une copie propose « Coller en texte brut » (XCUITest)
- Coller en texte brut ne modifie pas la copie gardée dans l'historique, qui garde tous ses formats (Swift Testing)
