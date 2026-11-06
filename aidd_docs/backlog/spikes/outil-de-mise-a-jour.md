---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_appkit/brainstorm.md
related_to:
  - aidd_docs/product/appkit.md
---

# Spike: outil de mise à jour automatique

## Question

Quel outil de mise à jour automatique AppKit doit-il utiliser hors App Store (Sparkle ou une alternative plus moderne), et sa signature des mises à jour est-elle compatible avec les recommandations de l'ANSSI ?

## Decision

La seule dépendance tierce autorisée d'AppKit, et la façon de signer les mises à jour.

## Bounds

- Evidence needed: l'état actuel de Sparkle (version, maintenance, compatibilité macOS 27), les alternatives existantes, et le statut d'Ed25519 dans les guides de l'ANSSI.
- Stop when: un outil est recommandé avec ses sources, et le statut d'Ed25519 est lu dans un guide de l'ANSSI.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| État de Sparkle | [Sparkle, releases](https://github.com/sparkle-project/Sparkle/releases) | Sparkle 2.10.1 est sorti le 25 octobre 2026. La 2.10.0 (13 septembre) corrige les mises à jour partielles sur macOS 27 et demande macOS 12 au minimum, parce qu'Xcode 27 ne vise plus les versions plus anciennes. Le projet est activement maintenu |
| Fonctionnement de Sparkle 2 | [Sparkle (fork Crystalnix)](https://github.com/Crystalnix/Sparkle) | Sparkle 2 vérifie chaque mise à jour par une signature EdDSA **et** par la signature de code d'Apple, et prend en charge les apps sandboxées |
| Alternatives | [SwiftUpdateKit](https://awesome.ecosyste.ms/projects/github.com%2Fn3v1%2Fswiftupdatekit) | Seule alternative en Swift trouvée : jeune, quasiment sans utilisateurs (1 étoile) |
| Statut d'Ed25519 pour l'ANSSI | [ANSSI, guide de sélection d'algorithmes cryptographiques, version 1.0 du 8 mars 2021](https://messervices.cyber.gouv.fr/documents-guides/anssi-guide-selection_crypto-1.0.pdf), section 6.2, recommandation R21 | Les mécanismes de signature recommandés sont RSA-PSS, KCDSA, SDSA, DSA, EC-KCDSA, EC-DSA, EC-GDSA, EC-SDSA et EC-FDSA. **EdDSA et Ed25519 n'y figurent pas**, même si la courbe Curve25519 fait partie des paramètres recommandés (section 5.3). Le guide insiste aussi : « la créativité n'est pas recommandée », il faut utiliser des bibliothèques éprouvées |

## Outcome

- Result: garder **Sparkle 2** (2.10.x), seule option mûre et maintenue, compatible macOS 27. Ed25519 n'est pas dans la liste des signatures recommandées par l'ANSSI en 2021. La chaîne de confiance principale d'AppKit reste donc la signature de code Developer ID et la notarisation d'Apple, que Sparkle et Gatekeeper vérifient à chaque mise à jour ; la signature Ed25519 de Sparkle s'y ajoute comme seconde couche, sans en être le fondement. Un outil de mise à jour écrit sur mesure avec les API d'Apple éviterait la dépendance, mais l'ANSSI déconseille de réinventer ce genre de mécanisme.
- Confidence: bonne pour Sparkle (dépôt officiel) et pour le guide de 2021 (texte lu) ; la version 3.00 du guide des mécanismes (mars 2026) n'a pas été vérifiée sur ce point.
- Remaining uncertainty: le statut d'EdDSA dans les guides de 2026 de l'ANSSI ; l'algorithme exact de la signature de code d'Apple.

## Follow-up

- Le brainstorm passe de « Sparkle, sauf alternative plus moderne » à « Sparkle 2 », avec la signature Developer ID et la notarisation comme chaîne de confiance principale, et Ed25519 en seconde couche.
- Vérifier le statut d'EdDSA dans le guide des mécanismes cryptographiques 3.00 avant la première release.
- Mettre à jour la question ouverte correspondante du brainstorm.
