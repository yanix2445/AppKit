---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 9
issue: "#21"
---

# Story: Retrouver mes textes enrichis, mes liens et mes couleurs

**As** un utilisateur de Mac
**I want** qu'AppKit reconnaisse les textes mis en forme, les liens et les couleurs
**So that** je les recolle tels quels et les repère d'un coup d'œil

## Acceptance

- Un texte enrichi (RTF, RTFD ou HTML) est gardé avec tous ses formats, se recolle avec sa mise en forme et s'affiche dans la catégorie Texte enrichi (Swift Testing et XCUITest)
- Une copie qui n'est qu'une adresse web, même copiée comme simple texte et espaces autour ignorés, s'affiche dans la catégorie Lien ; un texte qui contient une adresse parmi d'autres mots reste un Texte (Swift Testing)
- Une couleur copiée s'affiche dans la catégorie Couleur, avec une pastille (XCUITest)
- Une couleur écrite en texte (`#FF5733`, `rgb(255, 87, 51)`…) s'affiche aussi avec une pastille et se recolle comme texte (Swift Testing et XCUITest)
