---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/recoller-une-copie-de-texte.md
order: 5
---

# Story: Ouvrir le bandeau avec le raccourci global

**As** un utilisateur de Mac
**I want** ouvrir le bandeau de l'historique avec un raccourci clavier, depuis n'importe quelle app
**So that** je retrouve une copie sans lâcher le clavier ni chercher l'icône

## Acceptance

- ⇧⌘V ouvre le bandeau depuis n'importe quelle app, et le referme s'il est déjà ouvert (XCUITest)
- Le bandeau est visible en 100 ms au plus après le raccourci, et en 300 ms au plus la première fois après le démarrage de CopyKit (test de performance XCTest)
- À l'ouverture, la copie la plus récente est sélectionnée : Entrée la recolle aussitôt (XCUITest)
- Le bandeau s'ouvre sur l'écran où se trouve le pointeur (essai manuel avec deux écrans)
- Si ⇧⌘V est déjà pris par une autre app, comme Paste, CopyKit le dit clairement et propose un raccourci de secours parmi ⇧⌘C, ⌥⌘V et ⌃⌘V, ou d'en enregistrer un autre ; le bandeau reste accessible par l'icône de la barre de menus (Swift Testing et essai manuel avec Paste installé)
