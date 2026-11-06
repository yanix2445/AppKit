---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
order: 1
issue: "#13"
---

# Story: Voir mes dernières copies de texte dans le bandeau

**As** un utilisateur de Mac
**I want** voir mes dernières copies de texte dans un bandeau en bas de l'écran
**So that** je retrouve un texte copié il y a un instant sans avoir à le recopier

## Acceptance

- Un texte copié dans n'importe quelle app apparaît en tête de l'historique en moins de 50 ms après sa détection (Swift Testing)
- Le bandeau montre les copies de la plus récente à la plus ancienne, avec l'app source et l'heure (XCUITest)
- Un clic sur l'icône de la barre de menus ouvre le bandeau en bas de l'écran ; Échap ou un clic ailleurs le ferme (XCUITest)
- Une copie faite pendant que le bandeau est ouvert y apparaît aussitôt, sans changer la sélection en cours (XCUITest)
- L'historique ne vit qu'en mémoire : rien n'est écrit sur le disque, et il disparaît quand AppKit quitte (Swift Testing)
- Le presse-papiers est surveillé toutes les 0,5 s par son compteur, avec une tolérance qui laisse macOS regrouper les réveils (Swift Testing)
- Au repos, bandeau fermé, AppKit consomme en moyenne 0,1 % de CPU au plus sur une minute, et 80 Mo de mémoire au plus (test de performance XCTest, et essai manuel dans le Moniteur d'activité)
