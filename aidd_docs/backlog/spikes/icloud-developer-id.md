---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
related_to:
  - aidd_docs/product/copykit.md
---

# Spike: iCloud pour une app Developer ID

## Question

Une app macOS distribuée hors App Store, signée Developer ID, peut-elle utiliser CloudKit (base privée de l'utilisateur, champs chiffrés, `CKSyncEngine`) ?

## Decision

La faisabilité de la tranche 1.2 (synchronisation iCloud entre Mac) telle qu'elle est décidée.

## Bounds

- Evidence needed: une documentation Apple officielle sur les capacités disponibles en Developer ID, ou un essai signé qui lit et écrit dans la base privée.
- Stop when: une source Apple tranche, ou un essai réussit ou échoue de façon reproductible.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| Documentation Apple sur Developer ID | [Apple, Signing Mac Software with Developer ID](https://developer.apple.com/developer-id/) | Apple écrit qu'un logiciel signé avec un certificat Developer ID peut utiliser des capacités avancées, dont CloudKit et les notifications push |
| Documentation Apple sur les profils | [Apple, Developer ID certificates](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/) | Ces capacités passent par un profil de provisionnement Developer ID, vérifié par Gatekeeper à chaque lancement : s'il expire, l'app ne se lance plus. Les profils créés après le 22 février 2017 sont valables 18 ans |
| Historique | [Forums Apple, CloudKit hors Mac App Store](https://developer.apple.com/forums/thread/54125) | CloudKit est ouvert aux apps Developer ID depuis Xcode 8 et macOS 10.12 |
| Tableau des capacités macOS | [Apple, Supported capabilities (macOS)](https://developer.apple.com/help/account/reference/supported-capabilities-macos/) | La page liste CloudKit parmi les capacités par type de certificat, mais les valeurs du tableau n'ont pas pu être lues automatiquement |

## Outcome

- Result: oui. Une app signée Developer ID peut utiliser CloudKit, à condition d'être signée avec un profil de provisionnement Developer ID qui déclare la capacité iCloud et son conteneur. Les champs chiffrés et `CKSyncEngine` font partie de CloudKit ; aucune source ne les réserve à l'App Store. La tranche 1.2 est faisable telle que décidée.
- Confidence: bonne (documentation Apple officielle) ; à confirmer par un premier essai signé au début de la 1.2.
- Remaining uncertainty: le comportement réel des champs chiffrés et de `CKSyncEngine` dans une build Developer ID, à vérifier par un essai ; la lecture exacte du tableau des capacités, à faire dans un navigateur.

## Follow-up

- Signer CopyKit avec un profil de provisionnement Developer ID qui déclare iCloud (CloudKit) et le conteneur `iCloud.<identifiant de l'app>`. Le profil vaut 18 ans, mais son expiration empêcherait l'app de se lancer : le noter dans la checklist de release.
- Faire un premier essai signé (lecture et écriture dans la base privée, un champ chiffré) au début de la tranche 1.2.
- Mettre à jour la question ouverte correspondante du brainstorm.
