# Le plugin officiel Apple `xcode-integration`

← [Retour à l'index](README.md) · [Stack et architecture](03-stack-et-architecture.md) · [Workflow](02-workflow-macos.md)

Recherche faite le 2026-10-31, en suivant l'ordre de priorité de ton
`CLAUDE.md` : plugin officiel de l'éditeur → plugin communautaire → skill
officiel → skill communautaire.

## En bref

**Il existe un plugin Claude Code officiel d'Apple, et il est déjà sur ta
machine : il est livré avec Xcode 27.1.** C'est la priorité n°1, et la
référence pour tout ce qu'il couvre.

| Rang | Source | Type | Verdict |
| --- | --- | --- | --- |
| 1 | **`xcode-integration`** (Apple, dans Xcode 27.1) | plugin officiel : 15 skills + serveur MCP Xcode | ✅ à installer en premier |
| 2 | Paul Hudson (Hacking with Swift) : SwiftData Pro, Swift Concurrency Pro, Swift Testing Pro | 3 plugins communautaires | ✅ à ajouter : comblent les trous d'Apple (SwiftData, concurrence) et approfondissent Swift Testing |
| — | Paul Hudson : SwiftUI Pro | plugin communautaire | ❌ pas pour CopyKit : orienté iOS, doublon des skills SwiftUI d'Apple |
| 3 | Annuaire Anthropic : « SwiftUI guidance for macOS », `swift-lsp`, `liquid-glass` | plugins communautaires | ⚪ non nécessaires a priori |

---

## 0. Inventaire complet : tout ce qu'Apple fournit pour Claude Code

Relevé le 2026-10-31 sur la machine (Xcode 27.1, build 27A9275) et sur le web.

| Type | Ce qu'Apple fournit | Où | Statut |
| --- | --- | --- | --- |
| **Plugin** | `xcode-integration` 1.0.0, « Xcode-managed plugin for skills and services that integrate with the IDE » | généré par `xcrun mcpbridge run-agent plugin path --plugin-format claude` dans `~/Library/Developer/Xcode/CodingAssistant/ExportedPlugins/27A9275/claude/` | contient les skills et le MCP ci-dessous |
| **Skills** | 15 skills écrites par Apple (liste au §1) | dans le plugin ; exportables avec `xcrun mcpbridge run-agent skills export` | à installer |
| **Serveur MCP** | `xcode` : pont `xcrun mcpbridge` vers Xcode, serveur `xcode-tools`, 54 outils (liste au §1) | dans Xcode | à installer |
| **Gestion du serveur MCP** | `xcrun mcp-server` : mode sans fenêtre Xcode, autorisations des agents et des dossiers, journal d'activité | dans Xcode | outil, rien à installer |
| **Agents (sous-agents)** | aucun | — | — |
| **Hooks** | aucun | — | — |
| **Commandes slash** | aucune | — | — |
| **Agent Claude intégré à Xcode** | Xcode télécharge et lance son propre Claude Code (binaire signé par Anthropic), avec sa propre config (`ClaudeAgentConfig`), la télémétrie coupée et le MCP Xcode branché. Il recopie tes plugins Claude Code dans sa config (`AgentPlugins/`). Lancement en terminal : `xcrun mcpbridge run-agent claude` | `~/Library/Developer/Xcode/CodingAssistant/` | déjà là, utilisé par le panneau Intelligence d'Xcode |
| **Même contenu pour d'autres agents** | le plugin existe aussi aux formats Codex et Gemini (`--plugin-format codex`, `gemini`) | dans Xcode | non concerné |
| **Documentation Markdown pour l'IA** | 20 fiches qu'Xcode donne à ses fonctions IA, dont : `AppKit-Implementing-Liquid-Glass-Design`, `SwiftUI-Implementing-Liquid-Glass-Design`, `SwiftUI-New-Toolbar-Features`, `Swift-Concurrency-Updates`, `SwiftData-Class-Inheritance`, `AppIntents-Updates`, `FoundationModels-Using-on-device-LLM-in-your-app`, `Foundation-AttributedString-Updates`, `Swift-InlineArray-Span` | `/Applications/Xcode.app/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation/` | lisible par Claude à la demande, rien à installer |
| **Dépôts GitHub officiels (organisations `apple` ou `swiftlang`)** | aucun plugin ni skill pour Claude Code trouvé | — | — |

> Point à régler : l'agent Claude intégré à Xcode a recopié **BAMA** dans sa
> propre config (`AgentPlugins/bama`, et aussi pour Codex et Gemini) avant sa
> désinstallation. Le retirer depuis Xcode → Réglages → Intelligence, plutôt
> qu'en supprimant les fichiers à la main.

---

## 1. Le plugin officiel d'Apple : `xcode-integration`

### Ce que j'ai vérifié sur ta machine

- Xcode 27.1 contient les outils `xcrun mcpbridge` (pont MCP vers Xcode) et
  `xcrun mcp-server` (gestion du serveur, mode sans fenêtre Xcode).
- `xcrun mcpbridge run-agent plugin path --plugin-format claude` produit un
  **plugin au format Claude Code** dans
  `~/Library/Developer/Xcode/CodingAssistant/ExportedPlugins/27A9275/claude/` :
  - `.claude-plugin/plugin.json` : `"name": "xcode-integration"`, « Xcode-managed
    plugin for skills and services that integrate with the IDE » ;
  - `.mcp.json` : un serveur MCP `xcode` lancé par `xcrun mcpbridge` ;
  - `skills/` : 15 skills.
- Les skills commencent par : « This guidance was written and published by
  Apple » et disent qu'elles remplacent ce que le modèle a appris avant.

> Pour l'inspecter, j'ai lancé deux commandes Apple qui écrivent des fichiers :
> l'export des skills dans mon dossier temporaire, et la génération du plugin
> dans `~/Library/Developer/Xcode/CodingAssistant/ExportedPlugins/`. Rien n'a
> été installé dans Claude Code, ni modifié dans le projet.

### Les 15 skills Apple

| Skill | Ce qu'il apporte | Utile pour CopyKit |
| --- | --- | --- |
| `swiftui-specialist` | Bonnes pratiques et performance SwiftUI : structure des vues, flux de données, `@Observable`, Environment, identité dans `ForEach`/`List`, animations, localisation, APIs « soft-deprecated » | ✅ indispensable |
| `swiftui-whats-new-27` | Nouveautés SwiftUI 27 : `@State` devenu une macro (et la bonne correction des erreurs), `reorderable()`, swipe actions hors `List`, toolbar, `AsyncImage`, alertes depuis un binding optionnel | ✅ indispensable (SDK 27) |
| `modernize-tests` | Migrer vers Swift Testing et l'utiliser selon les recommandations ; rappelle que XCUITest et les `measure {}` restent en XCTest | ✅ |
| `app-intents-specialist` | Bonnes pratiques App Intents (modèle d'exécution, entités, requêtes, erreurs, phrases, donation) | ✅ dès qu'on expose des actions à Raccourcis / Spotlight |
| `app-intents-whats-new-27` | Nouveautés App Intents 26 et 27, dont les tests avec `AppIntentsTesting` | ✅ idem |
| `accessibility-voiceover-specialist` | Audit VoiceOver (labels, traits, contrôles custom) | ✅ |
| `accessibility-sufficient-contrast-specialist` | Audit des contrastes (WCAG 2.1) | ✅ |
| `accessibility-dynamic-type-specialist` | Audit de la taille de texte dynamique | ⚪ surtout iOS ; utile si l'app suit la taille de texte |
| `translation-coordinator` + `translation` | Traduire un projet via les String Catalogs (`.xcstrings`) | ✅ si l'app est multilingue |
| `audit-xcode-security-settings` | Activer progressivement les réglages de sécurité du build (warnings, analyseur statique, Enhanced Security) | ✅ en fin de milestone |
| `building-document-based-swiftui-applications` | Apps à documents (`DocumentGroup`, nouveau protocole `Document`) | ❌ sauf si CopyKit gère des fichiers documents |
| `device-interaction` | Vérifier l'app sur appareil ou simulateur (captures, hiérarchie d'UI, touches) | ⚪ pensé pour iOS ; à tester sur Mac |
| `app-resizability` | Adapter une app aux fenêtres redimensionnables (iPhone Duo, Stage Manager) | ❌ surtout iOS / iPadOS |
| `adopt-c-bounds-safety` | Extension C `-fbounds-safety` | ❌ pas de C |

### Le serveur MCP `xcode`

Il donne à Claude un accès direct au projet ouvert dans Xcode : c'est Xcode
lui-même qui compile, lance, teste et rend les Previews. Liste exacte obtenue
le 2026-10-31 en interrogeant `xcrun mcpbridge` (serveur `xcode-tools`,
version 25320) : 53 outils, plus `DocumentationSearch` qui n'apparaît que
une fois le plugin chargé dans Claude Code, soit **54 outils**.

| Domaine | Outils |
| --- | --- |
| Fichiers du projet (structure Xcode, pas le disque brut) | `XcodeRead`, `XcodeWrite`, `XcodeUpdate`, `XcodeGlob`, `XcodeGrep`, `XcodeLS`, `XcodeMV`, `XcodeMakeDir`, `XcodeRM` |
| Projet, cibles, schémas | `XcodeListWorkspaces`, `XcodeOpenWorkspace`, `XcodeCloseWorkspace`, `XcodeNewProject`, `XcodeListTemplates`, `XcodeListTargets`, `XcodeNewTarget`, `XcodeListSchemes`, `XcodeSwitchScheme`, `XcodeListRunDestinations`, `XcodeSwitchRunDestination` |
| Réglages de build | `GetTargetBuildSettings`, `UpdateTargetBuildSetting`, `GetFileCompilerFlags`, `UpdateFileCompilerFlags`, `AddEntitlement`, `AddInfoPlist` |
| Compiler et diagnostiquer | `BuildProject`, `GetBuildLog`, `XcodeRefreshCodeIssuesInFile` |
| Lancer et déboguer | `RunProject`, `StopProject`, `GetConsoleOutput` (stdout, stderr, OSLog), `InvokeDebuggerCommand` (lldb), `RunCodeSnippet` |
| Tests | `XcodeListTestPlans`, `XcodeSwitchTestPlan`, `GetTestList`, `RunAllTests`, `RunSomeTests` |
| Previews SwiftUI | `RenderPreview` (compile et renvoie une capture de la Preview) |
| Interagir avec l'app (appareil ou simulateur) | `DeviceInteractionStartSession`, `DeviceInteractionStartWorkspaceSession`, `DeviceInteractionInstallAndRun`, `DeviceInteractionSynthesize`, `DeviceInteractionEndSession` |
| Crashs et performance en production (service Apple) | `GetTopCrashIssues`, `GetCrashIssueLogs`, `GetTopFieldPerformanceIssues`, `GetFieldPerformanceIssueLogs` |
| Traduction (String Catalogs) | `LocalizationPlanner`, `StringCatalogRead`, `StringCatalogContext`, `StringCatalogEdit` |
| Documentation Apple | `DocumentationSearch` (recherche dans la documentation officielle) |

### Installation : ✅ faite le 2026-10-31

La commande officielle `xcrun mcpbridge run-agent skills export` n'exporte
que 10 skills sur 15 (sans les 3 d'accessibilité ni les 2 de traduction). On a
donc installé le **plugin complet** généré par Xcode, qui garde les noms
`xcode-integration:*` attendus par les outils Xcode :

```bash
# 1. Xcode génère le plugin au format Claude Code
xcrun mcpbridge run-agent plugin path --plugin-format claude
# 2. copie dans un marketplace local (~/.claude/local-marketplaces/apple-xcode/)
#    avec un marketplace.json qui ne référence que ce plugin
# 3. installation
claude plugin marketplace add ~/.claude/local-marketplaces/apple-xcode
claude plugin install xcode-integration@apple-xcode
```

Résultat vérifié :

- `claude plugin list` : `xcode-integration@apple-xcode` 1.0.0, scope user, ✔ enabled ;
- 15 skills dans le cache du plugin ;
- `claude mcp list` : `plugin:xcode-integration:xcode: xcrun mcpbridge - ✔ Connected`.

À savoir :

- Le pont se connecte à **Xcode ouvert**. Pour l'utiliser sans fenêtre :
  `sudo xcrun mcp-server enable` puis `xcrun mcp-server open CopyKit.xcodeproj`
  (le `sudo` te revient).
- **Après chaque mise à jour d'Xcode**, régénérer le plugin, le recopier dans
  le marketplace local, puis `claude plugin marketplace update apple-xcode` et
  `claude plugin update xcode-integration@apple-xcode`.
- Les skills et le MCP se chargent dans les **nouvelles** sessions Claude Code.
- Xcode sait aussi lancer son propre Claude : `xcrun mcpbridge run-agent claude`.

---

## 2. Ce qu'Apple ne couvre pas, et comment on fait

| Sujet sans skill Apple | Référence |
| --- | --- |
| Design et ergonomie macOS (fenêtres, toolbars, menus, Réglages, Liquid Glass) | [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) + principes de [03 §6](03-stack-et-architecture.md#6-principes-de-design) |
| Concurrence Swift 6 | `swift-concurrency-pro` de Paul Hudson (§3) + documentation Swift et Apple |
| SwiftData | `swiftdata-pro` de Paul Hudson (§3) + documentation Apple |
| APIs système macOS (presse-papiers, raccourci global, `NSPanel`, Accessibility, `SMAppService`) | documentation Apple ; chaque incertitude passe par un spike (`aidd-pm:05-spike`) |
| Architecture, cadrage, backlog, revue | AIDD + principes de [03 §5](03-stack-et-architecture.md#5-principes-darchitecture) |

Règle en cas de désaccord entre deux sources : **Apple a raison.**

---

## 3. Les alternatives communautaires

### Paul Hudson (Hacking with Swift) : analyse des 4 plugins

Paul Hudson est l'auteur de Hacking with Swift, une référence de
l'apprentissage Swift. Ses 4 dépôts ont été inspectés le 2026-10-31 :

| Plugin | Dépôt | ⭐ | Dernière mise à jour | Installation |
| --- | --- | --- | --- | --- |
| `swiftdata-pro` 1.0.0 | [SwiftData-Agent-Skill](https://github.com/twostraws/SwiftData-Agent-Skill) | 456 | 2026-10-19 | `swiftdata-pro@swiftdata-agent-skill` |
| `swift-concurrency-pro` 1.0.0 | [Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill) | 578 | 2026-05-17 | `swift-concurrency-pro@swift-concurrency-agent-skill` |
| `swift-testing-pro` 1.0.0 | [Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill) | 472 | 2026-05-17 | `swift-testing-pro@swift-testing-agent-skill` |
| `swiftui-pro` 2.0.0 | [SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) | 6 417 | 2026-10-26 | `swiftui-pro@swiftui-agent-skill` |

**Pas de bricolage** : chaque dépôt est un vrai plugin Claude Code
(`.claude-plugin/marketplace.json`) qui ne contient que du Markdown (un
`SKILL.md` et des références), des icônes et un fichier pour Codex. Aucun
script, aucun hook, aucun serveur MCP. Licence MIT. Les quatre poussent vers
les APIs Apple modernes et interdisent d'ajouter un framework tiers sans
demander.

| Plugin | Ce qu'il apporte | Face à Apple | Verdict |
| --- | --- | --- | --- |
| `swiftdata-pro` | Règles SwiftData : autosave, relations et règles de suppression, restrictions de propriétés, `FetchDescriptor`, prédicats qui plantent à l'exécution, index, héritage de modèles, contraintes CloudKit | Apple n'a **aucun** skill SwiftData | ✅ à installer |
| `swift-concurrency-pro` | Revue de la concurrence Swift 6 : motifs dangereux, réentrance des actors, concurrence structurée, annulation, `AsyncStream`, ponts avec les anciennes APIs, correspondance erreur du compilateur → correction ; refuse `@unchecked Sendable` comme rustine | Apple n'a **aucun** skill de concurrence | ✅ à installer |
| `swift-testing-pro` | Écrire et relire des tests Swift Testing : conventions, `#expect` / `#require`, injection de dépendances, tests async, `confirmation()`, limites de temps, attachments, migration depuis XCTest ; rappelle que les UI tests restent en XCTest | Complète `modernize-tests` d'Apple, plus détaillé | ✅ à installer |
| `swiftui-pro` | Revue SwiftUI très complète (APIs dépréciées, vues, données, navigation, accessibilité, performance) | Doublon de `swiftui-specialist` et `swiftui-whats-new-27` d'Apple. **Orienté iOS** : il pose iOS 27 comme cible par défaut, parle d'iPad et d'iPhone Duo, et ses références ne mentionnent presque jamais macOS | ❌ pas pour une app Mac |

Points de vigilance :

- `swift-concurrency-pro` et `swift-testing-pro` visent Swift 6.2 (mis à jour
  en mai 2026). Ils restent valables en Swift 6.4, mais en cas de désaccord,
  le compilateur et les skills Apple ont raison.
- `swift-testing-pro` propose Swift Numerics (package externe) pour comparer
  des nombres à virgule : à refuser, règle « zéro dépendance tierce ».

Installation (pas encore faite), dans une session Claude Code :

```text
/plugin marketplace add twostraws/SwiftData-Agent-Skill
/plugin install swiftdata-pro@swiftdata-agent-skill
/plugin marketplace add twostraws/Swift-Concurrency-Agent-Skill
/plugin install swift-concurrency-pro@swift-concurrency-agent-skill
/plugin marketplace add twostraws/Swift-Testing-Agent-Skill
/plugin install swift-testing-pro@swift-testing-agent-skill
```

### Annuaire de plugins Anthropic (non installés)

| Plugin | Ce que c'est | Avis |
| --- | --- | --- |
| SwiftUI guidance for macOS | Skill communautaire SwiftUI pour macOS (observation, concurrence, identité des vues), issu d'un navigateur macOS en production | ⚪ doublon partiel des skills Apple |
| `swift-lsp` | Diagnostics, définitions, références via SourceKit-LSP (le serveur de langage d'Apple), emballé par un tiers | ⚪ le MCP Xcode donne déjà les diagnostics |
| `liquid-glass` | Référence Liquid Glass, surtout iOS | ⚪ pensé pour iOS ; pour le Mac, les Human Interface Guidelines suffisent |

---

## 4. Recommandation

| Sujet | Plugin de référence |
| --- | --- |
| SwiftUI, SwiftUI 27 | Apple `swiftui-specialist`, `swiftui-whats-new-27` |
| SwiftData | Paul Hudson `swiftdata-pro` |
| Concurrence Swift 6 | Paul Hudson `swift-concurrency-pro` |
| Swift Testing | Apple `modernize-tests` + Paul Hudson `swift-testing-pro` |
| App Intents, accessibilité, traduction, sécurité du build | Apple |
| Design macOS | Human Interface Guidelines d'Apple |
| Méthode | AIDD |

1. **Installer le plugin Apple** (`xcode-integration` : MCP `xcode` + skills).
2. **Installer les 3 plugins de Paul Hudson** : `swiftdata-pro`,
   `swift-concurrency-pro`, `swift-testing-pro`.
3. **Ne pas installer `swiftui-pro`** : Apple couvre SwiftUI, et ses règles
   iOS donneraient de mauvais conseils sur Mac.
4. **Garder AIDD** pour la méthode.
5. En cas de désaccord entre deux skills : **Apple a raison**, puis le
   compilateur installé.

## Sources

- Vérifications locales : `xcrun mcpbridge`, `xcrun mcp-server`,
  `xcrun mcpbridge run-agent skills export`, `xcrun mcpbridge run-agent plugin path --plugin-format claude` (Xcode 27.1, build 27A9275).
- [Xcode 27 et le pont MCP d'Apple (article tiers)](https://codex.danielvaughan.com/2026/06/11/xcode-27-codex-cli-mcp-bridge-apple-agentic-coding-ios-macos-development/)
- [Serveur MCP Xcode 27 sans fenêtre avec Claude Code (article tiers)](https://mehmetbaykar.com/posts/how-to-run-xcode-27-mcp-server-headless-with-claude-code/)
- [Skill Axiom sur le MCP Xcode](https://skillselion.com/skills/charleswiltgen/axiom/axiom-xcode-mcp)
- [SwiftUI Agent Skill de Paul Hudson](https://www.hackingwithswift.com/articles/282/swiftui-agent-skill-claude-codex-ai)
- [Swift-Agent-Skills (annuaire)](https://github.com/twostraws/Swift-Agent-Skills/wiki)
- Dépôts inspectés avec `gh api` : [SwiftData-Agent-Skill](https://github.com/twostraws/SwiftData-Agent-Skill), [Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill), [Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill), [SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill)
