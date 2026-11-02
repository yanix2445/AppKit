---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/ne-jamais-garder-une-copie-confidentielle.md
order: 19
---

# Story: Exclure des apps

**As** un utilisateur de Mac
**I want** que les copies faites dans certaines apps ne soient jamais gardées
**So that** rien de ce que je copie dans mes outils sensibles ne reste dans l'historique

## Acceptance

- Par défaut, les copies faites dans l'app Mots de passe d'Apple, Trousseaux d'accès, 1Password, Bitwarden, Dashlane, Proton Pass, KeePassXC, Strongbox, MacPass, Enpass, NordPass, Keeper, LastPass et RoboForm ne sont jamais gardées, et leur contenu n'est jamais écrit sur le disque (Swift Testing)
- Ces apps sont reconnues par leur identifiant d'app, pas par leur nom ; l'app source vient du marqueur `org.nspasteboard.source` quand il existe, sinon de l'app active au moment de la copie (Swift Testing)
- Une app de la liste installée après coup est exclue dès son installation (Swift Testing)
- Les Réglages listent les apps exclues, avec la mention « par défaut » pour celles de la liste ; chacune peut être retirée, et n'importe quelle app peut être ajoutée (XCUITest)
