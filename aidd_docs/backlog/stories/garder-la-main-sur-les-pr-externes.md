---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
depends_on:
  - aidd_docs/backlog/stories/voir-les-tests-tourner-sur-chaque-pr.md
order: 2
---

# Story: Garder la main sur les PR externes

**As** Yanis, mainteneur d'AppKit
**I want** décider quand le code d'une PR externe tourne sur GitHub, et merger quand tout est vert
**So that** aucun code inconnu ne tourne sans mon accord, sans que je doive surveiller chaque PR

## Acceptance

- Les tests d'une PR venant d'un contributeur externe attendent mon accord, quel que soit le nombre de ses contributions passées (essai manuel)
- Les secrets du dépôt ne sont jamais transmis aux workflows d'une PR venant d'un fork (essai manuel)
- Une PR doit être à jour avec `main` avant d'être mergée, et je peux la mettre à jour moi-même depuis la PR (essai manuel)
- L'auto-merge est disponible : une PR que je valide se merge seule dès que ses tests passent (essai manuel)
