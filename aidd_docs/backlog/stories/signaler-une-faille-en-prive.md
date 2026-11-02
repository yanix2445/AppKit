---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
order: 9
---

# Story: Signaler une faille en privé

**As** un chercheur en sécurité
**I want** signaler une faille de CopyKit sans la rendre publique
**So that** elle soit corrigée avant que quelqu'un puisse l'exploiter

## Acceptance

- Le signalement privé de GitHub est activé sur le dépôt, et une adresse e-mail dédiée sert de secours (essai manuel)
- Le `SECURITY.md` dit ce qu'il faut fournir (description et impact, étapes pour reproduire, versions de CopyKit et de macOS), ce que fait CopyKit, et que seule la dernière version est corrigée (essai manuel)
- Une faille signalée reçoit un accusé de réception sous 7 jours, sa correction se prépare dans le fork privé de GitHub, et l'avis publié crédite la personne (essai manuel)
