---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
depends_on:
  - aidd_docs/backlog/stories/publier-un-dmg-signe-en-posant-un-tag.md
order: 6
---

# Story: Télécharger aussi le .zip et le .pkg, vérifiables

**As** un utilisateur de Mac
**I want** choisir le format d'installation et vérifier que mon téléchargement est intact
**So that** j'installe CopyKit comme je préfère, en sachant que le fichier n'a pas été modifié

## Acceptance

- Chaque release contient aussi un `.zip` avec `CopyKit.app` (notarisée et agrafée) et un `.pkg` signé Developer ID Installer et notarisé (essai manuel)
- Chaque fichier est accompagné de son empreinte SHA-256 (essai manuel)
- Chaque release publie la liste des composants de CopyKit (SBOM) et rappelle la durée de support : la dernière version est toujours corrigée (essai manuel)
