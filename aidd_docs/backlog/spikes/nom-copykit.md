---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_appkit/brainstorm.md
related_to:
  - aidd_docs/product/appkit.md
---

# Spike: disponibilité du nom CopyKit

> Historique : CopyKit était le nom de travail. Le nom définitif est AppKit, validé par Yanis le 2026-11-06.

## Question

Le nom « CopyKit » est-il déjà déposé comme marque pour des logiciels, ou utilisé par une app qui pourrait prêter à confusion ?

## Decision

Garder le nom ou en changer avant la première release publique.

## Bounds

- Evidence needed: une recherche dans les bases de marques de l'EUIPO, de l'INPI et de l'USPTO (classe 9 notamment), et sur l'App Store et le web.
- Stop when: les trois bases ont été consultées.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| Recherche web et App Store | [App Store, CopyKit (id6749535648)](https://apps.apple.com/us/app/copykit/id6749535648) | **Une app nommée « CopyKit » existe déjà sur l'App Store**, dans la catégorie Productivité : un gestionnaire de bouts de texte réutilisables pour iPad (catégories, champs variables, stockage local), à 0,99 $ ou gratuite selon les pays. Même nom, usage très proche |
| Recherche web de marques | [TrademarkDir, COPEKIT LLC](https://trademarkdir.com/owner/copekit-llc) | Aucune marque « CopyKit » trouvée par le web ; seulement des noms voisins (COPEKIT, CopyBucket), différents. Les bases officielles n'ont pas encore été consultées |

## Outcome

- Result: Yanis **garde le nom « CopyKit »**, en connaissance de cause : une app du même nom, dans la même catégorie, existe sur l'App Store (un gestionnaire de bouts de texte pour iPad). Le risque de confusion est accepté. Aucune marque « CopyKit » n'a été trouvée par le web.
- Confidence: bonne pour l'app existante (fiche App Store) ; faible pour les marques (bases officielles non consultées).
- Remaining uncertainty: les dépôts de marque à l'EUIPO, à l'INPI et à l'USPTO.

## Follow-up

- Avant la première release publique, consulter les bases officielles : [EUIPO eSearch](https://euipo.europa.eu/eSearch/), [INPI](https://data.inpi.fr/), [USPTO](https://tmsearch.uspto.gov/). Un dépôt de marque existant en classe 9 rouvrirait la décision.
- Mettre à jour la question ouverte correspondante du brainstorm.
