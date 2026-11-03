---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/ouvrir-le-bandeau-au-raccourci-global.md
order: 28
---

# Story: Personnaliser mes raccourcis

**As** un utilisateur de Mac
**I want** choisir moi-même chaque raccourci de CopyKit dans les Réglages
**So that** CopyKit s'adapte à mes habitudes et ne gêne jamais les raccourcis de mes autres apps

## Acceptance

- Une rubrique « Raccourcis » des Réglages liste chaque action avec son raccourci : ouvrir l'historique (⇧⌘V), mettre en pause ou reprendre la capture (aucun par défaut), coller (↩), coller en texte brut (⇧↩), supprimer (⌫), épingler ou désépingler (aucun par défaut), déplacer un épinglé à gauche ou à droite (⌥⌘← et ⌥⌘→) (XCUITest)
- Un clic sur un raccourci l'enregistre à la prochaine combinaison tapée ; Échap annule, un bouton l'efface, « Rétablir » revient au raccourci par défaut (XCUITest)
- Un raccourci déjà pris par macOS, par une autre app ou par une autre action de CopyKit est refusé avec la raison, sans rien changer (Swift Testing et XCUITest)
- Un raccourci global (ouvrir l'historique, pause) contient au moins ⌘, ⌃ ou ⌥ ; un raccourci du bandeau contient une touche de modification ou une touche spéciale comme ↩ ou ⌫ (Swift Testing)
- Un changement s'applique aussitôt, sans redémarrer CopyKit, et reste après un redémarrage (Swift Testing et XCUITest)
- Partout où CopyKit cite un raccourci (menu de l'icône, aide clavier du bandeau, astuces, onboarding), il affiche celui qui est choisi (XCUITest)
