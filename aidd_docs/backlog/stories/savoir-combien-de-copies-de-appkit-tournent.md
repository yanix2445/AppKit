---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
depends_on:
  - aidd_docs/backlog/stories/recevoir-les-mises-a-jour-automatiquement.md
order: 8
---

# Story: Savoir combien de copies d'AppKit tournent

**As** Yanis, mainteneur d'AppKit
**I want** compter, sans rien savoir des personnes, combien de copies d'AppKit vérifient leurs mises à jour
**So that** je sache si les gens gardent AppKit, sans trahir leur vie privée

## Acceptance

- Le nombre de vérifications de mises à jour est compté par jour (essai manuel)
- Aucune adresse IP ni aucun identifiant n'est conservé pour ce comptage, y compris dans les journaux de l'hébergeur : la conservation des journaux de Vercel est vérifiée et réglée, ou le comptage passe par un autre moyen (essai manuel en lisant ce qui est stocké)
- La politique de confidentialité décrit ce comptage (essai manuel)
