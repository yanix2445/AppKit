# VCS

The version-control conventions this project follows: branches, commits, and the platform.

## Setup

- Main branch: `main`
- Platform: `github` (`yanix2445/Copykit`, public)
- Tickets: GitHub Issues, lues avec `gh issue view <n>` ; le contenu détaillé vit aussi dans `aidd_docs/backlog/` (voir `backlog.md`)
- Hooks: aucun hook git versionné dans le dépôt. Dans le clone local (`.git/hooks/`, non versionné) : `pre-commit` refuse tout commit sur `main`, `pre-push` refuse tout push vers `main`, `post-merge` nettoie les branches mergées après un `git pull` sur `main`. Côté Claude Code, `protect-main.sh` bloque toute édition, tout commit et tout push sur `main`
- Protection GitHub : le ruleset « Protect main » impose une PR pour toute modification de `main`, sans approbation exigée, et interdit le force push et la suppression de `main`, sans exception, même pour le propriétaire
- Nettoyage : GitHub supprime la branche d'une PR dès qu'elle est mergée (`delete_branch_on_merge`) ; en local, `git sync` met `main` à jour sans checkout (ou par `git pull` si on est dessus) puis supprime les branches déjà mergées, ou dont la PR est mergée ; une branche avec du travail non mergé n'est jamais supprimée

## Branches

- Format: `claude/<description-courte-en-kebab-case>`
- Types in use: `claude/*` pour tout travail fait avec un agent ; une tâche, une branche
- Jamais de travail sur `main` : l'intégration passe par une PR draft que Yanis promeut et merge

## Commits

- Convention: Conventional Commits, en anglais
- Format: `type(scope): description`, types `feat`, `fix`, `docs`, `refactor`, `build`, `chore`, `test`
- Rules: impératif, minuscule, un sujet par commit, le corps explique le pourquoi, dernière ligne `Co-Authored-By` quand un agent a écrit le commit

## Commit Strategy

AI should auto commit: `after task done`
