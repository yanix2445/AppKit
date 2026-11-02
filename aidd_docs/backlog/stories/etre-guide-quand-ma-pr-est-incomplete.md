---
type: story
status: proposed
parent: aidd_docs/backlog/epics/installer-et-mettre-a-jour-en-confiance.md
depends_on:
  - aidd_docs/backlog/stories/proposer-une-idee-ou-une-contribution.md
order: 11
---

# Story: Être guidé quand ma PR est incomplète

**As** un contributeur
**I want** savoir exactement ce qui manque à ma PR
**So that** je la complète sans deviner ni attendre une relecture

## Acceptance

- Une PR sans issue liée (`Closes #n`), sans déclaration d'usage de l'IA ou sans étapes de test cochées reçoit un commentaire qui dit exactement ce qui manque, et la vérification reste en échec tant que ce n'est pas corrigé (essai manuel)
- Une PR qui modifie du code sans toucher aux tests reçoit un rappel gentil, sans blocage (essai manuel)
- Le commentaire est aussi posté sur une PR venue d'un fork, sans que le code de cette PR ne s'exécute jamais avec des droits d'écriture : un premier workflow vérifie sans droits, un second poste le commentaire à sa fin (essai manuel avec une PR de test venue d'un fork)
- Aucune PR n'est jamais fermée automatiquement (essai manuel)
