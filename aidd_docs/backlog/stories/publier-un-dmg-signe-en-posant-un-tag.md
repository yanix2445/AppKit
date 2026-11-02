---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
depends_on:
  - aidd_docs/backlog/stories/voir-les-tests-tourner-sur-chaque-pr.md
order: 3
---

# Story: Publier un .dmg signé et notarisé en posant un tag

**As** Yanis, mainteneur de CopyKit
**I want** qu'un tag de version produise tout seul une release avec un .dmg signé et notarisé
**So that** je publie une version sans manipulation à la main et sans risque d'erreur

## Acceptance

- Poser un tag `vX.Y.Z` sur `main` lance le workflow de release ; un autre tag ou une PR ne le lance jamais (essai manuel)
- La signature et la notarisation tournent dans l'environnement GitHub `release`, qui attend mon clic d'accord et seul détient les clés (essai manuel)
- Le `.dmg` est signé Developer ID, notarisé, avec le ticket agrafé, et s'ouvre sans alerte sur un Mac qui n'a jamais vu CopyKit (essai manuel)
- Si le tag ne correspond pas au numéro de version de l'app, le workflow s'arrête avant de signer, avec un message clair (essai manuel)
- Avant chaque release, un essai manuel dans une machine virtuelle macOS 26, créée avec le framework Virtualization d'Apple, confirme que CopyKit se lance et que ses parcours principaux fonctionnent (essai manuel)
- La release GitHub est immuable et ses notes sont générées à partir des PR, avec le nom de chaque contributeur (essai manuel)
