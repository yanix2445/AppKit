---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
depends_on:
  - aidd_docs/backlog/stories/publier-un-dmg-signe-en-posant-un-tag.md
order: 5
issue: "#45"
---

# Story: Recevoir les mises à jour automatiquement

**As** un utilisateur de Mac
**I want** qu'AppKit se mette à jour sans que j'aie à y penser
**So that** j'aie toujours les corrections et les nouveautés, en toute sécurité

## Acceptance

- AppKit vérifie les mises à jour chaque jour, sans rien demander, auprès du flux servi sur le domaine de Yanis (Swift Testing et essai manuel)
- Quand une version sort, une fenêtre montre ses nouveautés avec « Installer » et « Plus tard » ; une option des Réglages permet de tout installer sans demander (XCUITest et essai manuel)
- Une mise à jour dont la signature Developer ID, la notarisation ou la signature Ed25519 est fausse est refusée (essai manuel avec une mise à jour falsifiée)
- La vérification n'envoie aucun profil du Mac (Swift Testing)
- Une mise à jour marquée critique est mise en avant pour être installée vite (essai manuel)
- Sparkle fonctionne avec l'architecture `arm64e` d'AppKit ; sinon, l'authentification des pointeurs est désactivée sur la seule cible qui le lie (essai manuel)
