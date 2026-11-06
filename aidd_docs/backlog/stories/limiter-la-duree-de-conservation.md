---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/epingler-et-desepingler.md
order: 17
---

# Story: Limiter la durée de conservation

**As** un utilisateur de Mac
**I want** choisir combien de temps AppKit garde mes copies
**So that** mes vieilles copies ne traînent pas indéfiniment

## Acceptance

- Les Réglages proposent 1 jour, 1 semaine, 1 mois, 3 mois, 6 mois ou « jamais » ; 1 mois par défaut (XCUITest)
- Les copies plus anciennes que la durée choisie sont supprimées automatiquement, sauf les épinglés (Swift Testing)
- Réduire la durée ouvre d'abord une confirmation qui annonce l'impact exact (« Supprimer 1 240 éléments (3,2 Go) ? Les éléments épinglés ne sont pas touchés. »), avec Annuler par défaut, qui remet l'ancienne valeur, et Supprimer en bouton destructeur (XCUITest)
- Allonger la durée ne demande jamais de confirmation (XCUITest)
