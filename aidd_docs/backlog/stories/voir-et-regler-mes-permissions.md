---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/coller-directement-dans-l-app-active.md
  - aidd_docs/backlog/stories/lancer-copykit-a-l-ouverture-de-session.md
order: 25
---

# Story: Voir et régler mes permissions

**As** un utilisateur de Mac
**I want** voir en un coup d'œil les permissions dont CopyKit a besoin, et leur état
**So that** je comprenne ce qui marche, ce qui ne marche pas, et comment le régler

## Acceptance

- Une page « Permissions » des Réglages montre l'état de l'Accessibilité, de l'accès au presse-papiers et de l'ouverture de session, avec pour chacune ce qui ne marche pas sans elle et un bouton qui ouvre le bon réglage (XCUITest)
- L'état se met à jour à l'ouverture des Réglages et au retour depuis les Réglages Système (Swift Testing)
- Si macOS ne donne pas d'accord durable pour lire le presse-papiers (`accessBehavior` autre que « toujours autoriser »), CopyKit explique pourquoi il le lit avant la première lecture ; s'il le refuse, CopyKit explique ce qui ne marche pas et ouvre le bon réglage (Swift Testing et XCUITest)
