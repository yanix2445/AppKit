---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
order: 1
issue: "#41"
---

# Story: Voir les tests tourner sur chaque PR

**As** Yanis, mainteneur d'AppKit
**I want** que le build et les tests tournent sur GitHub pour chaque PR
**So that** une PR qui casse quelque chose ne puisse jamais arriver sur `main`

## Acceptance

- Chaque PR lance le build, les tests unitaires et les tests d'interface sur l'image GitHub `xcode-27`, avec une version d'Xcode choisie explicitement (essai manuel sur une PR)
- Le ruleset « Protect main » exige que ces tests passent avant tout merge (essai manuel : une PR aux tests en échec ne peut pas être mergée)
- Les résultats et les journaux des tests sont visibles depuis la PR (essai manuel)
