---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/retrouver-mes-textes-enrichis-liens-et-couleurs.md
order: 12
---

# Story: Ne pas avoir de doublons

**As** un utilisateur de Mac
**I want** qu'une même copie n'apparaisse qu'une fois dans l'historique
**So that** le bandeau reste clair, même quand je recopie souvent la même chose

## Acceptance

- Deux copies sont identiques quand tous leurs formats le sont, octet pour octet, en ignorant ceux qui varient à chaque copie, dont `org.chromium.internal.source-rfh-token`, `org.chromium.source-url` et `com.apple.WebKit.custom-pasteboard-data` (Swift Testing)
- La copie la plus récente remplace l'ancienne et remonte en tête, avec sa date et son app source ; elle garde la date de première copie et le nombre de copies (Swift Testing)
- Une même phrase avec une mise en forme différente reste un élément distinct (Swift Testing)
- Un doublon détecté en fin de traitement fusionne avec l'élément existant (Swift Testing)
