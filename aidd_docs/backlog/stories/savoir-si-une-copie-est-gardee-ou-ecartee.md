---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/exclure-des-apps.md
order: 23
issue: "#35"
---

# Story: Savoir si une copie est gardée ou écartée

**As** un utilisateur de Mac
**I want** un signal discret quand AppKit garde ou écarte une copie
**So that** je sache, sans ouvrir le bandeau, si ma copie a été gardée

## Acceptance

- Une copie écartée fait clignoter brièvement l'icône de la barre de menus, sans rien montrer de son contenu (XCUITest)
- Une copie écartée joue un son, une copie gardée en joue un autre ; ce sont deux sons système d'Apple discrets, activés par défaut (Swift Testing)
- Les Réglages permettent d'activer ou non chaque son et de le choisir (XCUITest)
- Aucun son n'est joué quand les effets sonores de l'interface sont désactivés dans macOS (essai manuel)
