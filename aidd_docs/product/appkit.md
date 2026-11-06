---
objective: "Donner à chaque utilisateur de Mac un gestionnaire de presse-papiers beau, simple, rapide et privé, gratuit et open source, qui remplace Paste au quotidien, avant d'y réunir les captures et la gestion des fenêtres."
revision: current
---

# Product Brief: AppKit

AppKit est une app de barre de menus macOS, gratuite et open source, qui réunit dans une seule app privée, rapide et sobre ce que font aujourd'hui Paste, CleanShot X et Swish. Elle s'adresse à tous les utilisateurs de Mac, débutants compris. L'idée est validée (brainstorm approuvé), aucun code n'est écrit.

## Opportunity

Garder un historique du presse-papiers sur Mac impose aujourd'hui un compromis :

- **Paste** est soigné et synchronise l'historique et les pinboards par iCloud, mais il est fermé et vendu en abonnement (2,49 $/mois ou 29,99 $/an, avec aussi une offre à vie) ;
- **Maccy** est gratuit et ouvert (MIT), mais minimaliste par choix et sans synchronisation : la demande, ouverte en 2020, attend toujours une contribution ;
- **Raycast** est soigné et inclut l'historique dans son offre gratuite, mais il le garde 3 mois (illimité et synchronisé avec l'offre Pro), il est fermé, et son historique n'est qu'une fonction d'un lanceur ;
- **Spotlight** (macOS 26) est intégré, mais désactivé par défaut, limité à 7 jours au plus, sans épinglés ni synchronisation.

S'équiper complètement coûte environ 50 $ par an (29,99 $ pour Paste et 19 $ pour les mises à jour de CleanShot X), plus deux licences (35 $ pour CleanShot X, 16 $ pour Swish), pour trois apps fermées, dont une qui voit tout ce qu'on copie. Il faut choisir entre une belle interface et l'ouverture et la confidentialité.

Pourquoi maintenant : SwiftUI et le design Liquid Glass de macOS 26 et 27 permettent à une personne seule de construire une app native moderne. Spotlight a fait découvrir l'historique au grand public sans répondre à l'usage durable, et Paste est passé à l'abonnement.

## Audience and Context

- **Yanis**, l'utilisateur de départ : il utilise Paste, CleanShot X et Swish au quotidien, sur plusieurs Mac.
- **Tous les utilisateurs de Mac**, y compris ceux qui n'ont jamais utilisé de gestionnaire de presse-papiers. Souvent, ils découvrent le besoin avec Spotlight. Ils veulent retrouver ce qu'ils ont copié sans rien régler.
- **Les utilisateurs avancés** (développeurs, designers, créateurs) qui connaissent Paste ou Maccy, et veulent clavier, réglages fins et vitesse.

Situation commune : copier-coller toute la journée, entre apps et entre Mac. Progrès voulu : ne plus jamais perdre une copie, la retrouver en un instant, sans craindre pour sa vie privée.

## Product Bet

Si AppKit offre la beauté et la simplicité de Paste avec l'ouverture et la confidentialité de Maccy, gratuitement, en natif Apple, simple par défaut et puissant sur demande, alors Yanis abandonnera Paste, et d'autres utilisateurs le garderont plutôt que Spotlight, Maccy ou Paste.

Ensuite, les captures (V2) et la gestion des fenêtres (V3) dans la même app remplaceront CleanShot X et Swish.

Le premier pari à valider est la V1.0 : un historique qui remplace Paste.

## Evidence and Assumptions

| Claim | Status | Basis or next check |
| --- | --- | --- |
| Spotlight est désactivé par défaut, limité à 30 min, 8 h ou 7 jours, sans épinglés ni synchronisation de l'historique | evidence | [MacRumors](https://www.macrumors.com/2025/11/04/more-spotlight-clipboard-settings-macos-26-1/), [MacMost](https://macmost.com/how-to-use-the-spotlight-clipboard-history-in-macos-tahoe.html) (macOS 26.1) et [DEV Community](https://dev.to/jrw0ng/macos-tahoe-has-built-in-clipboard-history-heres-what-its-still-missing-for-developers-2026-4eko) ; à revérifier sur macOS 27 |
| Paste coûte 2,49 $/mois ou 29,99 $/an, CleanShot X 35 $ avec un an de mises à jour puis 19 $/an, Swish 16 $ une fois | evidence | sites officiels : [Paste](https://pasteapp.io/pricing), [CleanShot](https://cleanshot.com/pricing), [Swish](https://highlyopinionated.co/swish/) |
| Raycast garde l'historique 3 mois en gratuit, illimité avec Pro, qui ajoute la synchronisation | evidence | [Raycast](https://www.raycast.com/pricing) ; à préciser si la synchronisation couvre l'historique |
| Maccy n'a pas de synchronisation entre Mac | evidence | [issue #182](https://github.com/p0deje/Maccy/issues/182), ouverte depuis 2020 |
| Maccy reste minimaliste par choix, et ceux qui veulent du soigné partent vers Paste ou Raycast | evidence | [MacRumors](https://forums.macrumors.com/threads/what-clipboard-manager-do-you-recommend-to-replace-paste.2470509/), [r/macapps](https://reddit.birdcat.cafe/r/macapps/comments/1iij0wz/best_clipboard_app), [TeenyApps](https://teenyapps-website.pages.dev/articles/maccy-alternatives.html) |
| Aucune app ne réunit belle interface, gratuité, code ouvert et confidentialité | assumption | revue concurrentielle plus large (AlternativeTo, Setapp) pendant l'étape B |
| Yanis remplacera Paste au quotidien | assumption | utiliser la V1.0 quatre semaines sans revenir à Paste |
| Des débutants adopteront AppKit s'il est simple par défaut | assumption | 5 testeurs débutants l'installent et s'en servent sans aide |
| Des utilisateurs garderont AppKit plutôt que Spotlight ou Maccy | assumption | bêta publique : comptage des vérifications de mises à jour semaine après semaine |
| Le cœur de la V1 est faisable en 100 % Apple : lecture du presse-papiers sans alerte, recherche chiffrée rapide, copies du presse-papiers universel | evidence | spikes de l'étape B, avec essais réels sur macOS 27.2 : [presse-papiers](../backlog/spikes/alerte-confidentialite-presse-papiers.md), [recherche chiffrée](../backlog/spikes/chiffrement-et-recherche.md), [presse-papiers universel](../backlog/spikes/presse-papiers-universel.md) |
| Une personne seule peut livrer et maintenir la V1 | assumption | rythme réel des tranches de la V1 |
| La synchronisation iCloud fonctionne pour une app Developer ID | evidence | [spike iCloud](../backlog/spikes/icloud-developer-id.md) (documentation Apple) ; premier essai signé au début de la 1.2 |
| AppKit est hors du champ du Cyber Resilience Act, tant que les dons restent volontaires | evidence | [spike CRA](../backlog/spikes/cyber-resilience-act.md) (guide de la Commission) ; relecture juridique avant la release |
| Go : AppKit est lancé, après les spikes de l'étape B | decision | décision de Yanis du 2 novembre 2026 |
| Hors App Sandbox, avec le chiffrement de l'historique comme protection principale | decision | [ADR hors App Sandbox](../memory/internal/decisions/hors-app-sandbox.md) |
| Sparkle 2 pour les mises à jour, avec la signature Developer ID et la notarisation comme chaîne de confiance principale | decision | [spike outil de mise à jour](../backlog/spikes/outil-de-mise-a-jour.md) |
| Le nom « AppKit » est gardé malgré une app iPad du même nom | decision | [spike nom](../backlog/spikes/nom-copykit.md) |
| 100 % Apple, sauf l'outil de mise à jour | decision | [brainstorm](../tasks/2026_10/2026_10_31_appkit/brainstorm.md) |
| Gratuit, open source (MIT), financé par des dons | decision | [brainstorm](../tasks/2026_10/2026_10_31_appkit/brainstorm.md) |
| Rien n'est envoyé sans accord, et l'app est conforme par conception (RGPD, CRA volontaire, ANSSI) | decision | [brainstorm](../tasks/2026_10/2026_10_31_appkit/brainstorm.md) |

## Boundaries

- Addresses: un historique du presse-papiers complet et privé (V1), puis les captures (V2) et la gestion des fenêtres (V3), sur Mac Apple silicon, à partir de macOS 26.
- Leaves out: dans la V1 (tranches 1.0 à 1.2), les captures (V2), la gestion des fenêtres (V3) et l'installation par Homebrew
- Leaves out: iPhone et iPad pour l'instant, Mac Intel, App Store, version payante, compte ou serveur propriétaire, statistiques sans accord, accès au contenu des copies par quiconque d'autre que l'utilisateur.

## Success

Résultat voulu : ne jamais perdre une copie et la retrouver en un instant, sans compromis sur la vie privée ni la sobriété.

- Pour Yanis : AppKit remplace Paste au quotidien, et tous ses tests passent.
- Indicateur de valeur : le nombre de copies d'AppKit qui vérifient leurs mises à jour chaque semaine (utilisateurs actifs hebdomadaires estimés, sans aucune donnée personnelle). Il montre que les gens **gardent** l'app.
- Garde-fous : les lignes rouges tiennent (CPU au repos ≤ 0,1 %, mémoire ≤ 80 Mo, aucun élément exclu gardé), et aucun incident de confidentialité.

## Validation and Feedback

**Prochaine vérification** : les spikes de l'étape B ont rendu le cœur de la V1 faisable, et la décision est **go**. Le risque principal est maintenant la valeur : Yanis utilise la V1.0 quatre semaines sans revenir à Paste, et 5 débutants l'installent et s'en servent sans aide.

**Retour après usage** : les téléchargements de chaque release (GitHub), le comptage anonyme des vérifications de mises à jour (site sur Vercel, sans adresse IP), les issues, Discussions, étoiles et dons. Yanis les regarde à chaque release et chaque mois. Ils peuvent changer l'ordre des tranches : avancer la synchronisation (1.2) si elle est très demandée, retravailler l'onboarding si les téléchargements ne deviennent pas des utilisateurs actifs, ou lancer la V2.

## Product View

| | Spotlight | Maccy | Paste | Raycast | **AppKit** |
| --- | --- | --- | --- | --- | --- |
| Prix | gratuit | gratuit | 2,49 $/mois, 29,99 $/an ou à vie | gratuit (historique) | **gratuit** |
| Code ouvert | non | oui (MIT) | non | non | **oui (MIT)** |
| Interface | intégrée à Spotlight | minimaliste | soignée | soignée | **soignée, native Apple** |
| Durée de l'historique | 30 min à 7 jours | selon le nombre d'éléments | illimitée | 3 mois (gratuit), illimitée (Pro) | **1 jour à « jamais »** |
| Épinglés | non | oui | oui (pinboards) | à vérifier | **oui, puis pinboards (1.1)** |
| Synchronisation entre Mac | non | non | oui | avec Pro, à préciser pour l'historique | **oui (1.2), l'historique local d'abord** |
| Historique chiffré par l'app | à vérifier | à vérifier | à vérifier | à vérifier | **oui (AES-256-GCM)** |

## Open Decisions

- Avant la première release publique : la marque « AppKit » dans les bases de l'EUIPO, de l'INPI et de l'USPTO, le statut d'EdDSA dans le guide 2026 de l'ANSSI, et une relecture juridique du Cyber Resilience Act.
