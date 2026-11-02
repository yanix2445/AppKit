# Plugins Claude Code : inventaire et guide d'utilisation

Documentation de découverte rédigée le 2026-10-31, à partir de la lecture des
fichiers `SKILL.md`, des agents et des hooks de chaque plugin. Aucun plugin
n'a été lancé pour coder.

## Les fichiers

| Fichier | Contenu |
| --- | --- |
| [README.md](README.md) | Ce fichier : ce qui est installé, l'état du projet |
| [01-aidd-framework.md](01-aidd-framework.md) | Les 6 plugins AIDD installés, skill par skill, plus leurs agents et leur hook |
| [02-workflow-macos.md](02-workflow-macos.md) | **L'ordre d'utilisation** pour construire CopyKit |
| [03-stack-et-architecture.md](03-stack-et-architecture.md) | La stack 100 % Apple (dernières versions) et les principes d'architecture, de design et de livraison |
| [04-plugin-apple-xcode.md](04-plugin-apple-xcode.md) | Le plugin **officiel Apple** `xcode-integration` livré avec Xcode 27.1 (15 skills + serveur MCP Xcode), et l'analyse des plugins de Paul Hudson |
| [05-architectures.md](05-architectures.md) | MVC, MVVM, MV, TCA, VIPER, Clean Architecture, organisation par feature : ce qu'Apple conseille et la recommandation pour CopyKit |
| [06-arborescence-et-nommage.md](06-arborescence-et-nommage.md) | L'arborescence complète des dossiers et fichiers, les suffixes par rôle et les règles d'import entre couches |
| [07-catalogue-skills-aidd.md](07-catalogue-skills-aidd.md) | **Les 47 skills AIDD installés** (et les 4 désinstallés), un par un : étape, rôle, fichiers produits, prérequis, enchaînements |

Pour démarrer : [03-stack-et-architecture.md](03-stack-et-architecture.md),
puis [02-workflow-macos.md](02-workflow-macos.md).

## La combinaison retenue

| Rôle | Qui |
| --- | --- |
| Outillage, frameworks, savoir Swift / SwiftUI / tests | **Apple** : Xcode 27.1 et son plugin officiel `xcode-integration` |
| SwiftData, concurrence | documentation Apple et Swift ; plugins de **Paul Hudson** analysés mais **non installés** (option) |
| Méthode (cadrage, plan, implémentation, revue, PR) | **AIDD** |
| Règles de conception | les principes de [03-stack-et-architecture.md](03-stack-et-architecture.md) + les Human Interface Guidelines d'Apple |

BAMA a été **désinstallé** le 2026-10-31 (plugin, marketplace et cache
supprimés) : on reste sur ce qui est officiel Apple.

## Vérification de l'installation

### AI-Driven Dev Framework (marketplace `aidd-framework`, v5.13.0)

| Plugin | Statut | Version installée | Skills |
| --- | --- | --- | --- |
| `aidd-context` | ✅ installé (stable) | 2.10.0 | 13 |
| `aidd-dev` | ✅ installé (stable) | 2.7.1 | 10 + 2 agents |
| `aidd-vcs` | ✅ installé (stable) | 2.5.0 | 6 |
| `aidd-pm` | ✅ installé (stable) | 2.6.0 | 10 |
| `aidd-refine` | ✅ installé (stable) | 3.1.2 | 5 |
| `aidd-orchestrator` | ✅ installé (stable) | 2.4.0 | 3 |
| `aidd-ui` | ⛔ désinstallé (🚧 alpha) | — | 1 (smoke-test) |
| `aidd-telemetry` | ⛔ désinstallé (🧪 beta) | — | 2 + 3 hooks |
| `aidd-qa` | ⛔ désinstallé (🆕 new) | — | 1 |

**Installés : 6 plugins, 47 skills, 2 agents.** Les 3 autres ont été essayés
puis désinstallés le 2026-10-31 : ils n'apportent rien à une app macOS native
(détails dans [07](07-catalogue-skills-aidd.md#les-3-plugins-hors-parcours-recommandé)).

**Vérifié le 2026-10-31 contre le dépôt officiel** (`ai-driven-dev/framework`,
release v5.13.0) : les 6 plugins sont à leur dernière version et **identiques
à l'octet près**, et tout ce que déclarent leurs manifestes est présent.
Procédure : [07](07-catalogue-skills-aidd.md#vérifier-une-installation).

> Le cache contient aussi d'anciennes versions (par exemple
> `aidd-context/2.8.1`). Claude Code charge la version listée dans
> `~/.claude/plugins/installed_plugins.json`.

### Plugin officiel Apple `xcode-integration` : ✅ installé (2026-10-31)

Livré avec Xcode 27.1 : 15 skills écrites par Apple (SwiftUI, SwiftUI 27,
Swift Testing, App Intents, accessibilité, traduction, sécurité du build…) et
un serveur MCP `xcode` (`xcrun mcpbridge`). Installé depuis un marketplace local `apple-xcode`, serveur MCP connecté. Détails et installation :
[04-plugin-apple-xcode.md](04-plugin-apple-xcode.md).

### Pré-requis techniques (vérifiés sur cette machine)

| Pré-requis | Pour | Sur la machine |
| --- | --- | --- |
| Xcode | tout | ✅ Xcode 27.1 (dernière version stable), Swift 6.4, SDK macOS 27.0 |
| macOS | | ✅ 27.0.1 |
| Outils Apple (`swift-format`, `xcresulttool`, `xctrace`, `notarytool`, `docc`, `mcpbridge`, `mcp-server`) | stack native, plugin Apple | ✅ tous présents dans Xcode 27.1 |
| Apps Apple (Instruments, Icon Composer, Accessibility Inspector) | performance, icône, accessibilité | ✅ livrées avec Xcode |
| `git` | AIDD | ✅ |
| `gh` (GitHub CLI) | `aidd-vcs` (PR, issues), `async-dev` | ✅ `/opt/homebrew/bin/gh` |
| Node 22+ | hook `SessionStart` d'`aidd-context` | ✅ `/opt/homebrew/bin/node` (version non vérifiée) |

## État actuel du projet CopyKit

Le dépôt contient le **template Xcode par défaut** (pas encore de code
métier) : `CopyKit.xcodeproj`, `CopyKit/` (`CopyKitApp.swift`,
`ContentView.swift`, `Item.swift` en SwiftData), `CopyKitTests/`,
`CopyKitUITests/`. Réglages : cible macOS 27.0, catégorie Productivity, isolation
main-actor par défaut, Swift Testing, dossiers synchronisés, signature
automatique avec ton équipe, `SWIFT_VERSION = 5.0`, `ENABLE_APP_SANDBOX = YES`.

Le cadre retenu (détails dans [03-stack-et-architecture.md](03-stack-et-architecture.md)) :

1. **100 % natif Apple** : projet Xcode, zéro dépendance tierce, outils Apple.
2. **Mode de langage Swift 6** à activer (seul réglage à changer).
3. **App Sandbox** à décider au brief.

## Autres plugins installés (hors périmètre)

`impeccable`, `interfaces`, `marketing-skills`, `openrouter`, `convex`,
`vercel`, `cloudflare`, `resend`, `gsap-skills`, `higgsfield`, `plugin-dev`,
`skill-creator`, `hookify`, `mcp-server-dev`. Ils ne servent pas au
développement de l'app. `marketing-skills:aso` pourra servir pour une fiche
App Store si tu publies un jour.
