---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
related_to:
  - aidd_docs/product/copykit.md
---

# Spike: chiffrement et vitesse de recherche

## Question

Avec un historique chiffré en AES-256-GCM, la recherche reste-t-elle sous 50 ms pour 10 000 éléments et sous 150 ms pour 100 000 sur un Mac Apple silicon ?

## Decision

L'architecture du stockage et de l'index de recherche : ce qui est chiffré, ce qui est gardé en mémoire, et comment on cherche.

## Bounds

- Evidence needed: une mesure sur ce Mac, avec un banc d'essai jetable, d'au moins deux approches (déchiffrer à chaque recherche, ou garder en mémoire un index déchiffré au démarrage).
- Stop when: une approche tient les deux seuils avec une mémoire compatible avec la limite de 80 Mo au repos, ou aucune ne les tient.

## Investigation

Banc d'essai jetable en Swift 6.4 (CryptoKit, compilé en `-O`, lancé par Portly) sur le Mac Apple silicon de Yanis, macOS 27.2, le 2 novembre 2026. Historique synthétique : des textes de 3 à 200 mots, environ 440 octets en moyenne (4,4 Mo pour 10 000 éléments, 44 Mo pour 100 000), chaque élément chiffré à part en AES-256-GCM. Requête : « réunion facture », insensible à la casse et aux accents.

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| A : déchiffrer chaque élément à chaque recherche | Banc d'essai | 397 ms pour 10 000, 3 926 ms pour 100 000 : **rate les deux seuils** |
| B : déchiffrer une fois, garder un tableau de `String` normalisées, chercher avec `contains` | Banc d'essai | Chargement 66 ms et 650 ms ; recherche 82 ms et 755 ms : **rate les deux seuils** |
| C : même index que B, recherche répartie sur tous les cœurs | Banc d'essai | 17 ms pour 10 000, mais 180 ms pour 100 000 : **rate le seuil de 100 000** |
| D : texte de recherche normalisé (casse et accents) calculé à la copie et chiffré à part ; à l'ouverture de l'historique, tout est déchiffré dans un seul tampon d'octets contigu ; recherche avec `memmem` et une recherche dichotomique pour retrouver l'élément | Banc d'essai | Ouverture 8 ms et 79 ms ; recherche **3,8 ms pour 10 000** et **40,5 ms pour 100 000** ; mémoire de l'index +4 Mo et +40 Mo : **tient les deux seuils** |

## Outcome

- Result: oui, à condition de bien construire l'index. Déchiffrer à la volée est exclu, et même un index de chaînes Swift en mémoire est trop lent. L'approche D tient largement les seuils : moins de 4 ms pour 10 000 éléments et environ 40 ms pour 100 000, soit 12 fois et 3,5 fois sous les limites, avec une ouverture de l'historique en moins de 80 ms.
- Confidence: bonne pour l'ordre de grandeur (mesure réelle, reproductible) ; moyenne pour les vrais historiques, dont les textes peuvent être bien plus longs que ceux du banc d'essai.
- Remaining uncertainty: le coût réel avec de longs textes (journaux, code collé), une recherche à plusieurs mots indépendants, la recherche dans les noms de fichiers et les couleurs, et la mémoire réelle de l'app complète.

## Follow-up

- Retenir pour la conception (étape D) : le texte de recherche normalisé est calculé une fois, à la copie, et chiffré à part du contenu ; l'index de recherche est un tampon d'octets contigu, déchiffré à l'ouverture de l'historique et libéré à sa fermeture, ce qui respecte la limite de 80 Mo au repos.
- Plafonner le texte indexé par élément (par exemple les 64 premiers Ko) pour borner la taille de l'index, et chercher chaque mot de la requête séparément.
- Ajouter ces scénarios aux tests de performance automatiques, avec des historiques réalistes.
- Mettre à jour la question ouverte correspondante du brainstorm.
