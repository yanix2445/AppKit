---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/epingler-et-desepingler.md
order: 18
issue: "#30"
---

# Story: Limiter la place prise sur le disque

**As** un utilisateur de Mac
**I want** fixer la place maximale de mon historique et voir celle qu'il occupe
**So that** AppKit n'encombre jamais mon disque

## Acceptance

- La limite vaut 1 Go par défaut, ce qui est aussi son minimum, et se règle jusqu'à 10 Go (XCUITest)
- Quand la limite est atteinte, les plus vieilles copies non épinglées sont supprimées (Swift Testing)
- Les Réglages affichent la place réelle sur le disque, vignettes comprises, avec les épinglés à part (« Historique : 650 Mo / 1 Go · Épinglés : 300 Mo ») (Swift Testing et XCUITest)
- Réduire la limite ou choisir « Tout effacer » ouvre la même confirmation que pour la durée, avec l'impact exact ; les épinglés et les copies volumineuses temporaires ne sont pas touchés (XCUITest)
