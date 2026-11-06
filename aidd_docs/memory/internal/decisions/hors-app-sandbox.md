# AppKit hors App Sandbox

- Date: 2026-11-02
- Status: Accepted

## Context

AppKit est distribué hors App Store, signé Developer ID et notarisé. Le
projet Xcode a été créé avec l'App Sandbox et le Hardened Runtime activés
(`ENABLE_APP_SANDBOX = YES`, `ENABLE_HARDENED_RUNTIME = YES`).

Le sandbox n'est obligatoire que sur l'App Store. Il protège l'utilisateur en
limitant ce que l'app peut faire, mais AppKit doit, par nature, voir tout ce
qui est copié, coller dans les autres apps et, en V3, déplacer leurs fenêtres.

Le spike [sandbox](../../../backlog/spikes/sandbox.md) a vérifié chaque
fonction, avec des essais réels sur macOS 27.2 et des réponses d'ingénieurs
d'Apple :

| Fonction | En sandbox | Hors sandbox |
| --- | --- | --- |
| Lire le presse-papiers en arrière-plan | possible, sans alerte | possible, sans alerte |
| Coller dans l'app active (⌘V par `CGEvent`) | possible, avec l'autorisation « poster des événements » | possible, avec la permission Accessibilité |
| Garder un fichier copié depuis le Finder | possible, après l'accord de macOS pour le dossier, avec un bookmark sécurisé | possible, après l'accord de macOS pour le dossier |
| Garder une photo arrivée de l'iPhone par le presse-papiers universel | **impossible** : le fichier temporaire du système est illisible | possible |
| Déplacer et redimensionner les fenêtres des autres apps (V3) | **impossible** : les API d'Accessibilité ne sont pas prises en charge en sandbox | possible, avec la permission Accessibilité |
| Protéger les fichiers de l'historique contre les autres apps | protégés par le conteneur de l'app (macOS 14 et plus) | lisibles par les autres apps non sandboxées de l'utilisateur |

## Decision

AppKit est construit **hors App Sandbox** (`ENABLE_APP_SANDBOX = NO`), avec
le Hardened Runtime, la signature Developer ID et la notarisation. Le
chiffrement de l'historique (AES-256-GCM, clé dans le Trousseau « protection
des données ») devient la protection principale des données sur le disque.

## Alternatives

| Alternative | Raison |
| --- | --- |
| Garder le sandbox pour toute l'app | Perd les photos venues de l'iPhone dès la V1 et rend la V3 impossible |
| Sandbox pour la V1, puis le retirer en V3 | Retirer le sandbox change l'emplacement des données (conteneur) et donc impose une migration ; et les photos de l'iPhone resteraient perdues en V1 |
| Une app sandboxée avec un assistant non sandboxé à part | Deux binaires, une communication XPC et deux surfaces à signer et à maintenir, pour une protection que le chiffrement apporte déjà |
| Passer par l'App Store | Exclu par le brainstorm ; un gestionnaire de presse-papiers a de plus été refusé pour l'envoi de ⌘V (règle 2.4.5) |

## Consequences

- ✅ Toutes les fonctions décidées sont possibles, de la V1 à la V3, dans une
  seule app.
- ✅ Les données restent au même endroit d'une version à l'autre : aucune
  migration de conteneur à prévoir.
- ⚠️ Sans conteneur, la sécurité des données repose sur le chiffrement : la
  clé ne doit jamais apparaître en clair sur le disque, et aucune copie ne
  doit être écrite en clair, même temporairement. Ces deux points sont
  vérifiés par des tests et en revue (`aidd-dev:05-review`).
- ⚠️ AppKit ne pourra pas passer sur l'App Store sans une refonte.
- ⚠️ Chaque permission se demande au moment où elle sert, avec une phrase qui
  dit ce qui ne marche pas sans elle : Accessibilité pour le collage direct
  et la gestion des fenêtres, accès aux dossiers protégés (Bureau, Documents,
  Téléchargements) pour lire un fichier copié.
- ⚠️ Le Hardened Runtime ne reçoit aucune exception tant qu'aucune fonction ne
  l'exige.
- Le réglage `ENABLE_APP_SANDBOX` passe à `NO` avec la première story (étape E
  du workflow), par l'outil MCP `UpdateTargetBuildSetting`, comme le veut la
  règle du projet.
