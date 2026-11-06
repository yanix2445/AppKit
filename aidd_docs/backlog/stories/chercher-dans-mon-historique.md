---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 13
issue: "#25"
---

# Story: Chercher dans mon historique

**As** un utilisateur de Mac
**I want** taper quelques lettres pour trouver une copie
**So that** je la retrouve même si elle date de plusieurs jours

## Acceptance

- Bandeau ouvert, taper des lettres filtre aussitôt l'historique, sans tenir compte des majuscules ni des accents (XCUITest)
- Un résultat contient tous les mots de la requête, chacun cherché séparément, dans le texte, les liens, les noms de fichiers et les couleurs ; chaque mot ajouté affine la recherche (Swift Testing)
- Les résultats arrivent en 50 ms au plus pour 10 000 éléments et en 150 ms au plus pour 100 000, historique chiffré compris (test de performance XCTest)
- Échap efface la recherche, puis ferme le bandeau (XCUITest)
