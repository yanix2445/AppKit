---
type: spike
status: in-progress
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
related_to:
  - aidd_docs/product/copykit.md
---

# Spike: disponibilité du nom CopyKit

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

- Result: en cours. Le risque de confusion est déjà réel, indépendamment de toute marque déposée : une app du même nom, dans la même catégorie, existe sur l'App Store.
- Confidence: bonne pour l'app existante (fiche App Store) ; faible pour les marques (bases officielles non consultées).
- Remaining uncertainty: les dépôts de marque à l'EUIPO, à l'INPI et à l'USPTO.

## Follow-up

- Consulter les bases officielles : [EUIPO eSearch](https://euipo.europa.eu/eSearch/), [INPI](https://data.inpi.fr/), [USPTO](https://tmsearch.uspto.gov/).
- Décision de Yanis : garder « CopyKit » malgré l'app existante, ou choisir un autre nom avant la première release publique.
