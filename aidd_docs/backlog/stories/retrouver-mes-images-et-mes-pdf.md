---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 8
issue: "#20"
---

# Story: Retrouver mes images et mes PDF

**As** un utilisateur de Mac
**I want** retrouver dans le bandeau les images et les PDF que j'ai copiés
**So that** je recolle une capture d'écran ou un document sans le refaire

## Acceptance

- Une image copiée (PNG, TIFF, JPEG, HEIC ou GIF) est gardée avec tous ses formats, et se recolle identique à l'original, octet pour octet (Swift Testing)
- Un PDF copié est gardé et se recolle identique à l'original (Swift Testing)
- Chaque image et chaque PDF s'affiche avec une vignette, dans la catégorie Image ou PDF (XCUITest)
- Une grosse image apparaît dans le bandeau en 50 ms au plus ; si son traitement dépasse 0,5 seconde, une icône et un petit anneau de progression s'affichent jusqu'à la vignette (Swift Testing et XCUITest)
- Une copie encore en traitement se recolle tout de suite, identique à l'original (Swift Testing)
