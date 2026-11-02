---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 21
---

# Story: Mettre la capture en pause

**As** un utilisateur de Mac
**I want** suspendre la capture pendant un moment
**So that** ce que je copie pendant une tâche sensible ne soit pas gardé

## Acceptance

- Le menu de l'icône de la barre de menus propose : 5 minutes, 1 heure, jusqu'à réactivation, ou ignorer la prochaine copie (XCUITest)
- Pendant la pause, aucune copie n'est gardée ni écrite sur le disque (Swift Testing)
- L'icône de la barre de menus montre que la capture est en pause (XCUITest)
- La capture reprend seule à la fin de la durée choisie, ou après la copie ignorée (Swift Testing)
