---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_appkit/brainstorm.md
related_to:
  - aidd_docs/product/appkit.md
---

# Spike: copies du presse-papiers universel

## Question

Une copie arrivée d'un iPhone, d'un iPad ou d'un autre Mac par le presse-papiers universel est-elle visible et lisible par une app du Mac qui surveille le presse-papiers, et comment la reconnaître ?

## Decision

Garder ou non ces copies dans l'historique d'AppKit, et comment les traiter (marqueur, app source, contenu téléchargé à la demande).

## Bounds

- Evidence needed: une copie faite sur l'iPhone de Yanis, observée sur ce Mac : changement du compteur, types présents (dont `com.apple.is-remote-clipboard`), lecture du contenu possible ou non.
- Stop when: les types et la lisibilité d'une copie distante sont observés au moins une fois.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| Documentation | [nspasteboard.org](http://nspasteboard.org/), [Apple, presse-papiers universel](https://support.apple.com/en-us/102430) | Apple marque une copie arrivée d'un autre appareil par Handoff du type `com.apple.is-remote-clipboard`. Les appareils doivent être proches, sur le même compte Apple, et le contenu n'y reste que brièvement |
| Essai réel, macOS 27.2 et iPhone de Yanis : l'app jetable du spike sur l'alerte de confidentialité, complétée pour repérer le marqueur et mesurer chaque lecture | Journal de l'essai, 2 novembre 2026 | Un texte copié dans Messages sur l'iPhone fait monter le compteur du presse-papiers du Mac tout seul. Types : `com.apple.uikit.attributedstring`, `com.apple.flat-rtfd`, `public.utf8-plain-text`, `public.text` et `com.apple.is-remote-clipboard`. La première lecture du texte prend 220 ms (le temps de le récupérer sur l'iPhone), les suivantes moins d'1 ms. Aucun marqueur `org.nspasteboard.source` |
| Même essai, une photo copiée dans Photos sur l'iPhone | Journal de l'essai | La photo arrive comme un **fichier** : `public.file-url`, `com.apple.mobileslideshow.asset.localidentifier` et `com.apple.is-remote-clipboard`, sans texte. Le fichier (un JPEG de 3,4 Mo) est rangé par macOS dans un dossier temporaire de `useractivityd` (`~/Library/Group Containers/group.com.apple.coreservices.useractivityd/shared-pasteboard/items/`) |

## Outcome

- Result: oui. Une copie du presse-papiers universel est visible et lisible par AppKit comme n'importe quelle copie, et elle se reconnaît au marqueur `com.apple.is-remote-clipboard`. Le texte arrive avec ses formats enrichis ; une photo arrive comme un fichier rangé dans un dossier temporaire du système. La première lecture coûte le temps du transfert depuis l'autre appareil (220 ms pour un court texte).
- Confidence: bonne (essai réel avec un texte et une photo).
- Remaining uncertainty: le temps de transfert d'une grosse photo ou d'une vidéo, non mesuré ; la durée de vie exacte du fichier temporaire ; le comportement depuis un iPad ou un autre Mac, non testés.

## Follow-up

- AppKit garde les copies du presse-papiers universel dans l'historique, avec un badge « depuis l'iPhone » (ou l'appareil d'origine si macOS le donne), puisque l'app source n'est pas fournie.
- Une copie distante qui arrive comme un fichier temporaire est gardée **avec son contenu**, pas par référence : son dossier appartient au système et disparaît. Elle suit alors la règle des copies volumineuses si elle dépasse le seuil.
- La lecture d'une copie distante se fait hors du fil principal, puisque la première lecture attend le transfert : c'est déjà la règle du traitement en arrière-plan.
- Une copie distante ne doit pas être renvoyée par la synchronisation d'AppKit vers l'appareil qui l'a envoyée : à traiter par la règle des doublons.
- Mettre à jour la question ouverte correspondante du brainstorm.
