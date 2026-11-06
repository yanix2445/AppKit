---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
depends_on:
  - aidd_docs/backlog/stories/publier-un-dmg-signe-en-posant-un-tag.md
order: 4
issue: "#44"
---

# Story: Télécharger AppKit depuis le site

**As** un utilisateur de Mac
**I want** télécharger AppKit en un clic depuis le site de Yanis
**So that** j'installe la dernière version, sans chercher sur GitHub

## Acceptance

- Le bouton « Télécharger » du site pointe vers le lien stable de GitHub pour le `.dmg` de la dernière version (essai manuel)
- Après une nouvelle release, le bouton télécharge la nouvelle version sans aucune modification du site (essai manuel)
- Le `.dmg` téléchargé s'installe en glissant AppKit dans Applications, sans alerte de Gatekeeper (essai manuel sur un Mac qui n'a jamais vu AppKit)
