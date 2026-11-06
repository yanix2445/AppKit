---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 25
issue: "#37"
---

# Story: Lancer AppKit à l'ouverture de session

**As** un utilisateur de Mac
**I want** qu'AppKit démarre tout seul quand j'ouvre ma session
**So that** je ne rate aucune copie après un redémarrage

## Acceptance

- À la première ouverture, AppKit propose de se lancer à l'ouverture de session, avec la raison : « pour ne rater aucune copie après un redémarrage » (XCUITest)
- Les Réglages permettent de l'activer ou de le désactiver à tout moment, et reflètent l'état réel dans macOS, même s'il a été changé dans les Réglages Système (Swift Testing et XCUITest)
- Quand le lancement automatique est désactivé, AppKit le signale discrètement (XCUITest)
- Après l'ouverture de session, AppKit est prêt à capter en 1 seconde au plus (test de performance XCTest et essai manuel)
