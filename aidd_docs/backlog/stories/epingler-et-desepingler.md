---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 15
---

# Story: Épingler et désépingler

**As** un utilisateur de Mac
**I want** épingler une copie pour la garder à part
**So that** je l'aie toujours sous la main, à l'abri du nettoyage

## Acceptance

- Le menu contextuel d'une copie propose Épingler ou Désépingler (XCUITest)
- Les épinglés s'affichent dans une section à part, dans l'ordre que je choisis en les déplaçant (XCUITest)
- Au clavier, ⌥⌘← et ⌥⌘→ déplacent l'épinglé sélectionné d'un cran dans sa section (XCUITest)
- Dans l'historique, un épinglé garde sa place chronologique, avec un badge (XCUITest)
- Un épinglé n'est jamais supprimé par le nettoyage automatique et ne compte pas dans la limite de stockage (Swift Testing)
- Recopier un épinglé le garde épinglé, à la même place dans la section (Swift Testing)
