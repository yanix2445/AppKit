---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 16
---

# Story: Supprimer une copie

**As** un utilisateur de Mac
**I want** supprimer une copie précise de mon historique
**So that** je retire une copie que je ne veux plus garder, sans effacer tout le reste

## Acceptance

- La touche ⌫ sur une copie sélectionnée, ou « Supprimer » dans son menu contextuel, la retire aussitôt du bandeau, sans confirmation (XCUITest)
- ⌘Z annule la dernière suppression tant que le bandeau reste ouvert (XCUITest)
- Une copie supprimée, épinglée ou non, est effacée du disque et de l'index de recherche à la fermeture du bandeau, quand ⌘Z ne peut plus la rappeler (Swift Testing)
