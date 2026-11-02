---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/limiter-la-place-sur-le-disque.md
order: 19
---

# Story: Garder temporairement une copie volumineuse

**As** un utilisateur de Mac
**I want** qu'une copie énorme soit gardée un moment sans vider mon historique
**So that** je puisse la recoller, sans perdre mes autres copies

## Acceptance

- Une copie qui dépasse le seuil « volumineux » (10 % de la limite, donc 100 Mo par défaut, réglable) est gardée à part, chiffrée, sans compter dans la limite ni rien supprimer d'autre (Swift Testing)
- Elle porte le badge « Volumineux · temporaire » (XCUITest)
- Elle est supprimée après 24 h (réglable) ou dès qu'une autre copie volumineuse arrive (Swift Testing)
- Épinglée, elle devient permanente et sort de la limite comme tout épinglé (Swift Testing)
- Le seuil porte sur ce que CopyKit stocke : une photo arrivée de l'iPhone compte pour son contenu, un fichier du Finder gardé par référence n'est jamais volumineux (Swift Testing)
