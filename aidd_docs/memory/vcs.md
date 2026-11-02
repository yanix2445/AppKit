# VCS

The version-control conventions this project follows: branches, commits, and the platform.

## Setup

- Main branch: `main`
- Platform: `github` (`yanix2445/Copykit`, public)
- Tickets: GitHub Issues, lues avec `gh issue view <n>` ; le contenu détaillé vit aussi dans `aidd_docs/backlog/` (voir `backlog.md`)
- Hooks: aucun hook git dans le dépôt ; côté Claude Code, `protect-main.sh` bloque toute édition, tout commit et tout push sur `main`

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
