---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/retrouver-mes-images-et-mes-pdf.md
order: 24
---

# Story: Retrouver les copies venues de mon iPhone

**As** un utilisateur de Mac qui a aussi un iPhone ou un iPad
**I want** que les copies arrivées par le presse-papiers universel soient gardées comme les autres
**So that** je retrouve sur mon Mac ce que j'ai copié sur mon iPhone

## Acceptance

- Une copie marquée `com.apple.is-remote-clipboard` est gardée, avec un badge qui indique qu'elle vient d'un autre appareil (Swift Testing et XCUITest)
- Une photo arrivée comme fichier temporaire du système est gardée avec son contenu, pas par référence (Swift Testing)
- La première lecture, qui attend le transfert depuis l'autre appareil, ne fige jamais le bandeau ni CopyKit (Swift Testing)
- Les règles de confidentialité s'appliquent aussi à ces copies (Swift Testing)
- Un texte et une photo copiés sur l'iPhone de Yanis apparaissent dans le bandeau du Mac (essai manuel)
