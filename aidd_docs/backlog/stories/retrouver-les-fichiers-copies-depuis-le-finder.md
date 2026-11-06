---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/garder-mon-historique-chiffre.md
order: 10
---

# Story: Retrouver les fichiers copiés depuis le Finder

**As** un utilisateur de Mac
**I want** retrouver les fichiers que j'ai copiés dans le Finder
**So that** je les recolle comme de vrais fichiers, sans en dupliquer le contenu

## Acceptance

- Un ou plusieurs fichiers copiés dans le Finder sont gardés par référence, sans copier leur contenu, et s'affichent dans la catégorie Fichier(s) avec leur nom et leur icône (Swift Testing et XCUITest)
- Recoller l'élément colle une vraie copie des fichiers, dans le Finder comme dans une app (XCUITest)
- Un fichier supprimé ou déplacé entre-temps s'affiche « introuvable » (Swift Testing)
- Un fichier gardé par référence n'est jamais une copie volumineuse, quelle que soit sa taille (Swift Testing)
- Avant la première lecture d'un fichier rangé dans un dossier protégé (Bureau, Documents, Téléchargements), AppKit explique pourquoi macOS va demander l'accès (essai manuel)
