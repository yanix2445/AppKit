---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/voir-et-regler-mes-permissions.md
order: 27
---

# Story: Découvrir CopyKit avec l'onboarding

**As** un utilisateur de Mac qui n'a jamais utilisé de gestionnaire de presse-papiers
**I want** une courte présentation à la première ouverture
**So that** je comprenne CopyKit et m'en serve tout de suite, sans rien régler

## Acceptance

- À la première ouverture, un onboarding court montre les actions clés : copier, ouvrir le bandeau avec ⇧⌘V, retrouver une copie récente, la recoller, l'épingler (XCUITest)
- Il se relance à tout moment depuis les Réglages (XCUITest)
- Les réglages par défaut rendent CopyKit utile dès l'installation, sans aucun réglage à faire (XCUITest)
- Une explication courte apparaît à la première utilisation du collage direct, de l'épinglage, de la recherche et de la pause, puis plus jamais (XCUITest)
- Les réglages avancés restent séparés des réglages essentiels (XCUITest)
- Une personne qui n'a jamais utilisé de gestionnaire de presse-papiers installe CopyKit, retrouve une copie et la recolle sans aide (essai manuel)
