---
type: epic
status: proposed
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
goal: aidd_docs/product/copykit.md
depends_on:
  - aidd_docs/backlog/epics/historique-complet-et-prive.md
order: 3
---

# Epic: Organiser et coller plus vite

Avec CopyKit 1.1, l'utilisateur range ses copies utiles dans des collections et
colle ce dont il a besoin plus vite, au clavier comme à la souris.

## Context and Value

Une fois l'historique fiable, les utilisateurs de Paste attendent de pouvoir
garder à portée de main ce qu'ils recollent souvent (adresses, réponses types,
bouts de code) et d'aller plus vite que copier-coller un élément à la fois.
C'est ce qui fait de CopyKit un vrai remplaçant de Paste au quotidien, et pas
seulement un historique.

## Boundaries

- Includes: les pinboards, des collections nommées et organisées d'éléments
- Includes: donner un nom personnalisé à une copie, gardé quand elle est recopiée
- Includes: le collage multiple
- Excludes: épingler et désépingler un élément, déjà livré par l'epic 1
- Excludes: les raccourcis personnalisables, déjà livrés par l'epic 1
- Excludes: la synchronisation des pinboards entre Mac (epic 4)

## Success Evidence

Yanis retrouve dans les pinboards de CopyKit ce qu'il range aujourd'hui dans
ceux de Paste, et n'utilise plus les pinboards de Paste. Les tests
automatiques couvrent la création, la modification et la suppression des
pinboards et le collage multiple.

## Dependencies and Unknowns

| Item | Kind | Handling |
| --- | --- | --- |
| Historique complet et privé | dependency | `depends_on` |
| Forme exacte du collage multiple (plusieurs éléments à la suite, ou combinés en un seul collage) | decision | à trancher par Yanis au découpage de la tranche 1.1 |
