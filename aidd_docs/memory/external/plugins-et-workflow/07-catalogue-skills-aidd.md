# Catalogue complet des skills AIDD

← [Retour à l'index](README.md) · Vue par plugin : [01-aidd-framework.md](01-aidd-framework.md) · Étapes : [02-workflow-macos.md](02-workflow-macos.md)

Relevé le 2026-10-31 sur les versions installées, à partir des fichiers
`SKILL.md` **et** de leurs actions et références (414 fichiers). Pour chaque
skill, on indique : l'étape du workflow où il sert, ce qu'il produit et où, ce
qu'il lit ou exige, et quels autres skills il appelle.

## Combien de skills ?

| Plugin | Version | Skills | En plus |
| --- | --- | --- | --- |
| `aidd-context` | 2.10.0 | 13 | hook `SessionStart` (synchronise la mémoire dans `CLAUDE.md`) |
| `aidd-dev` | 2.7.1 | 10 | 2 agents : `executor`, `checker` |
| `aidd-vcs` | 2.5.0 | 6 | |
| `aidd-pm` | 2.6.0 | 10 | |
| `aidd-refine` | 3.1.2 | 5 | |
| `aidd-orchestrator` | 2.4.0 | 3 | |
| **Total installé** | | **47** | 6 plugins, 47 skills, 2 agents |
| `aidd-ui` 0.2.1-alpha.0, `aidd-telemetry` 0.4.0, `aidd-qa` 1.0.0 | | 4 | **désinstallés** le 2026-10-31 après essai |
| **Total du framework** | | **51** | 9 plugins |

Légende des étapes : **0** fondations · **A** comprendre le besoin · **B**
valider l'opportunité · **C** cadrer la V1 · **D** concevoir et planifier ·
**E** construire · **F** vérifier · **G** livrer et apprendre · **T**
transverse (à tout moment).


## Changements de la mise à jour du 2026-10-31

| Plugin | Avant → après | Ce qui change |
| --- | --- | --- |
| `aidd-context` | 2.9.0 → 2.10.0 | `05-rule-generate` réécrit (comparaison avec les règles existantes, évaluation, accord explicite avant écriture) ; le modèle `vcs.md` de la mémoire gagne deux lignes : **Tickets** (outil et lecture d'un ticket) et **Hooks** (ce qui tourne au commit et au push) |
| `aidd-dev` | 2.7.0 → 2.7.1 | `01-plan` restructuré en 3 actions, wireframe par phase, validation par script Node, relecture par un sous-agent indépendant ; agents inchangés |
| `aidd-refine` | 3.1.1 → 3.1.2 | `01-brainstorm` allégé « pour les petits modèles » : 3 actions, une carte de découverte, le brief peut rester dans la conversation |
| `aidd-pm`, `aidd-vcs`, `aidd-orchestrator` | inchangés | — |

⚠️ **Incident d'installation corrigé** : après la mise à jour, la copie
installée de `aidd-dev` 2.7.1 n'avait plus son dossier `agents/`, alors que son
manifeste et la source du marketplace déclarent `executor` et `checker`. Sans
eux, `aidd-orchestrator:01-sdlc` ne peut plus déléguer l'implémentation ni la
revue. Réparé en réinstallant le plugin (`claude plugin uninstall` puis
`install aidd-dev@aidd-framework`). À vérifier après chaque mise à jour :
`ls ~/.claude/plugins/cache/aidd-framework/aidd-dev/*/agents`.

---

## Où AIDD range ses fichiers

AIDD écrit tout dans **`aidd_docs/`** à la racine du dépôt. C'est là que vivront
le brief, le backlog, les plans et la mémoire, mais aussi les décisions
(`memory/internal/decisions/`) et cette documentation
(`memory/external/plugins-et-workflow/`).

```text
aidd_docs/
├── memory/                     mémoire projet (02-project-memory)
│   ├── README.md               index, tenu à jour par le hook
│   ├── project-brief.md · architecture.md · codebase-map.md
│   ├── coding-assertions.md    ← commandes que 03-assert exécute
│   ├── testing.md · vcs.md     ← vcs.md : conventions lues par commit et pull-request
│   ├── desktop.md · database.md · design.md …   capacités détectées
│   └── internal/decisions/     décisions capturées par 10-learn
├── product/<produit>.md        Product Brief (06-product-brief)
├── backlog/
│   ├── epics/  stories/  spikes/  defects/  tasks/
├── tasks/<aaaa_mm>/<aaaa_mm_jj>_<slug>/
│   ├── brainstorm.md           (01-brainstorm)
│   ├── plan.md + phases        (01-plan)
│   └── revues, spec, PRD       (05-review, 04-spec, 03-prd)
├── tasks/<aaaa_mm>/<aaaa_mm_jj>_audit/   rapports d'audit (04-audit)
├── rules/<catégorie>/<règle>.md          règles de code (05-rule-generate)
└── recipes/<recette>.md                  recettes (12-cook)
```

> `aidd_docs/` sera un nouveau dossier à la racine : selon la règle du
> `CLAUDE.md`, il faudra le déclarer comme dossier synchronisé sans cible pour
> le voir dans Xcode.

### La mémoire projet, par capacités

`02-project-memory` détecte des **capacités** et crée un fichier de mémoire
pour chacune. Pour CopyKit, on attend :

| Capacité | Pourquoi | Détection automatique ? |
| --- | --- | --- |
| `core` | tout projet | ✅ toujours |
| `ecosystem` | outils externes (Xcode, plugins) | ✅ toujours |
| `desktop` | app de bureau native | ⚠️ le signal cherche AppKit, Qt, Electron… ; SwiftUI sur macOS est à **confirmer à la main** |
| `database` | SwiftData | ⚠️ le signal cherche un ORM ou des migrations ; à **confirmer à la main** |
| `ui` | interface | ⚠️ le signal vise le web ; à **confirmer à la main** |
| `backlog` | backlog local | ✅ dès que `aidd_docs/backlog/` existe |
| `deployment` | build et distribution | plus tard, avec une CI |

Le fichier **`coding-assertions.md`** est crucial : `aidd-dev:03-assert` exécute
les commandes qui y sont écrites. Il devra contenir nos commandes
`xcodebuild … test`.

---

## 🧭 aidd-context (13)

| Skill | Étape | Rôle | Produit | Lit ou exige | Appelle |
| --- | --- | --- | --- | --- | --- |
| `00-onboard` | 0, T | Point d'entrée : lit le projet, le classe, propose l'étape suivante dans un menu, n'agit qu'après ta réponse | un écran, rien sur disque | `aidd_docs/memory/` | 01-bootstrap, 02-project-memory, 11-explore, refine:01-brainstorm, orchestrator:01-sdlc, dev:04-audit, 06-test, 08-debug |
| `01-bootstrap` | — | Architecte d'un **SaaS** : checklist de 24 points, 2-3 stacks comparées | `aidd_docs/INSTALL.md` | — | — |
| `02-project-memory` | 0 | Crée (`setup`), met à jour (`refresh`) ou rebranche (`rewire`) la mémoire du projet | `aidd_docs/memory/*`, bloc dans `CLAUDE.md` | le code | 04-skill-generate |
| `03-context-generate` | T | Aiguille vers le bon générateur quand on ne sait pas quel artefact créer | — | — | 04 à 08 |
| `04-skill-generate` | T | Crée ou modifie un skill (router + actions) | dossier de skill | — | — |
| `05-rule-generate` | T | Crée, modifie, publie ou supprime une règle de code. Depuis 2.10.0 : cadre la règle, la **compare aux règles existantes**, l'évalue et te montre un candidat ; n'écrit qu'après ton accord explicite sur ce candidat | `aidd_docs/rules/<catégorie>/<règle>.md` + publication par outil IA (script Node `write-rule.cjs`) | les règles existantes | — |
| `06-agent-generate` | T | Crée un agent spécialisé | fichier d'agent | — | — |
| `07-command-generate` | T | Crée une commande slash | fichier de commande | — | — |
| `08-hook-generate` | T | Crée un hook (script lancé à un événement) | entrée de settings + script | — | — |
| `09-mermaid` | D, T | Diagramme Mermaid : plan → ta confirmation → génération → revue | bloc ```mermaid | un texte source | — |
| `10-learn` | G, T | Capture une leçon durable, la note, la range (mémoire, décision, règle, skill) | `aidd_docs/memory/internal/decisions/<slug>.md`… | conversation, fichier, diff ou revue | 05-rule-generate ou 04-skill-generate (passage de relais) |
| `11-explore` | T | Cartographie outillage, contexte et code ; pointe vers le bon skill sans le lancer | un écran | `aidd_docs/memory/`, `aidd_docs/rules/` | — |
| `12-cook` | T | Gère des recettes : lister, rechercher, créer, appliquer, valider | `aidd_docs/recipes/<recette>.md` | — | — |

## 🪞 aidd-refine (5)

| Skill | Étape | Rôle | Produit | Remarque |
| --- | --- | --- | --- | --- |
| `01-brainstorm` | **A** | Rend une idée floue précise par des questions. Depuis 3.1.2 : capture → explore (questions guidées par une carte : acteur et douleur, déclencheur et comportement, non-objectifs et plus petite version utile, contraintes et permissions, preuve que ça marche, cas limites) → conclude (brief à approuver). Ne planifie et ne code jamais | au choix : la conversation, `aidd_docs/tasks/<…>_<slug>/brainstorm.md` (`status: approved`), ou un ticket | n'écrit rien sans ton choix ; tu peux l'arrêter à tout moment pour un résumé |
| `02-challenge` | D, **F** | Remet en cause un travail fini face au plan : deal-breaker, suggestion ou correct, avec un score de confiance | rapport (modèle fixe) | utilisé par `01-sdlc` après la revue |
| `03-shadow-areas` | A, B, C | Cherche les angles morts d'un document : 7 catégories, 3 gravités, une question par trou ; mode `diff` sur une 2ᵉ passe | rapport, `status: clean` s'il ne reste ni bloquant ni majeur | ne modifie jamais le document |
| `04-fact-check` | B | Vérifie les affirmations d'un texte (mémoire → code → web en dernier) et le réécrit avec des sources | texte corrigé + `## Sources` + `## Unverified claims` | ne garde rien sans ton accord |
| `05-improve` | T | Analyse une conversation finie pour réduire le temps et les tokens perdus | rapport temporaire | n'édite rien |

## 📋 aidd-pm (10)

Règles communes : les décisions produit restent à toi ; preuves, décisions et
hypothèses sont séparées ; **rien n'est écrit sans ton accord**.

| Skill | Étape | Rôle | Produit |
| --- | --- | --- | --- |
| `06-product-brief` | **B** | Product Brief : opportunité, cible, alternatives, preuves, comment valider. Étapes : cadrer → découvrir → visualiser → rédiger → valider | `aidd_docs/product/<produit>.md` |
| `05-spike` | B, C, D | Investigation bornée d'une incertitude (faisabilité, estimation, conception) | `aidd_docs/backlog/spikes/<slug>.md` |
| `03-prd` | C *(option)* | Product Requirements Document : le quoi et le pourquoi | `aidd_docs/tasks/<…>-<feature>-prd.md` |
| `07-epic` | **C** | Un Epic orienté résultat | `aidd_docs/backlog/epics/<slug>.md` |
| `02-user-stories` | **C** | Stories découpées en tranches verticales, ordonnées, avec critères d'acceptation ; n'invente ni estimation ni priorité | `aidd_docs/backlog/stories/<slug>.md` |
| `08-three-amigos` | C | Évalue un Epic ou une Story sous un angle (produit, delivery ou qualité), puis réconcilie trois rapports | des propositions, rien sur disque |
| `04-spec` | D | Spec = contrat immuable d'une feature, sans solution, sans lire le code | `spec.md` dans `aidd_docs/tasks/<…>/` |
| `10-task` | C, E | Tâche technique bornée sans valeur utilisateur directe | `aidd_docs/backlog/tasks/<slug>.md` |
| `09-defect` | F, G | Enregistre un écart observé (sans le diagnostiquer) | `aidd_docs/backlog/defects/<slug>.md` |
| `01-ticket-info` | E | Affiche un ticket de l'outil de ticketing configuré | un affichage |

## ⚙️ aidd-dev (10 + 2 agents)

| Skill | Étape | Rôle | Produit | Lit ou exige |
| --- | --- | --- | --- | --- |
| `01-plan` | **D** | Plan par phases. Depuis 2.7.1 : capture (la source) → explore (lit le code, relève les constats : fichiers, impacts, règles, docs officielles consultées ; te pose les questions bloquantes) → conclude (phases livrables seules, wireframe ASCII pour chaque phase qui construit un écran, validation par script, puis relecture par un sous-agent indépendant) | `aidd_docs/tasks/<…>_<feature>/plan.md` + `phase-<n>.md` | la story ou la demande ; **Node** pour `scripts/validate-plan.cjs` |
| `02-implement` | **E** | Exécute un plan phase par phase ; statuts `pending → in-progress → implemented` ; **un commit local par tâche validée** | code, tests, commits | un `plan.md` |
| `03-assert` | **E**, F | Lance les assertions du projet et corrige jusqu'au vert ; facettes architecture (rapport seul) et frontend (navigateur) | verdict pass ou fail | **`aidd_docs/memory/coding-assertions.md`** |
| `06-test` | E | `test` : trouve ce qui n'est pas testé et écrit les tests ; `test-journey` : parcours dans un **navigateur** | tests | — |
| `08-debug` | E, F | `reproduce` (test qui échoue → correctif → PR), `debug` (hypothèses), `reflect-issue` (enquête bloquée) | correctif, fichier de suivi | — |
| `05-review` | **F** | Revue statique d'un diff : qualité, conformité au plan, pertinence ; verdict `approve`, `changes-requested` ou `blocked` | rapport dans `aidd_docs/tasks/<…>/` | le diff, le plan |
| `04-audit` | F | Audit **en lecture seule** sur 7 piliers (qualité, architecture, sécurité, dépendances, performance, tests, UI) | `aidd_docs/tasks/<…>_audit/<pilier>.md` + `report.md` | — |
| `07-refactor` | F | Améliore le code sur 4 axes, comportement préservé ; peut prendre un rapport d'audit comme liste | code, commits | rapport d'audit (option) |
| `09-for-sure` | T | Boucle autonome jusqu'à ce qu'une commande de succès passe ; **agit à ta place** sauf paiement ou destruction | `aidd_docs/tasks/<tâche>.md` | une commande de succès |
| `10-batch` | E | Découpe en tâches indépendantes exécutées en parallèle | un résumé par agent | — |
| agent `executor` | E | Transforme une tâche en code validé ; décide du comment, jamais du quoi | — | appelle implement, assert, test, debug, vcs:commit |
| agent `checker` | F | Juge un travail fini dans un contexte vierge, exige des preuves | verdict + score | appelle review, audit, refine:challenge |

## 🌿 aidd-vcs (6)

| Skill | Étape | Rôle | Lit |
| --- | --- | --- | --- |
| `00-repo-init` | — | `git init`, branche par défaut, `CONTRIBUTING.md`, remote | — *(déjà fait pour CopyKit)* |
| `01-commit` | E, G | Commits conventionnels, un sujet par commit ; `auto`, `interactive`, `push` | **`aidd_docs/memory/vcs.md`** |
| `02-pull-request` | **G** | PR **draft** ; base déduite du préfixe de branche ; ne commite ni ne pousse | **`aidd_docs/memory/vcs.md`** |
| `03-release-tag` | **G** | Version semver, tag annoté, notes ; te fait tout valider | — |
| `04-issue-create` | B, C, F | Crée une issue dans l'outil de ticketing (ici GitHub via `gh`) après ton accord | — |
| `05-resolve-conflict` | T | Résout les conflits Git déterministes, propose les autres | — |

## 🎼 aidd-orchestrator (3)

| Skill | Étape | Rôle | Enchaîne |
| --- | --- | --- | --- |
| `01-sdlc` | D → G | Une demande → une PR draft. Modes `auto` ou `interactive` (3 pauses : contrat, plan, résultat) | pm:01-ticket-info, refine:01-brainstorm, pm:04-spec, dev:01-plan, agent executor (02-implement, 03-assert, 06-test), vcs:01-commit, agent checker (05-review, refine:02-challenge), dev:10-batch, vcs:02-pull-request |
| `02-backlog` | C, T | Pilote le backlog : `ask`, `create`, `manage`, `review`, `refine` ; délègue l'écriture aux skills `aidd-pm` | les skills `aidd-pm` choisis selon le besoin |
| `00-async-dev` | — | Issues GitHub labellisées → PR automatiques, via un workflow CI ou un poll local | dev:02-implement, dev:05-review, 01-sdlc |

---

## Les 3 plugins hors parcours recommandé

Installés puis **désinstallés** le 2026-10-31 : ils n'apportent rien à une app
macOS native. Ce qui suit reste pour mémoire.

| Skill | Étape | Rôle | Pour CopyKit |
| --- | --- | --- | --- |
| `aidd-ui:01-hello` | — | Test de chargement : confirme seulement que le plugin répond. Aucune capacité UI ou UX réelle pour l'instant | ❌ inutile tant que le plugin est en alpha |
| `aidd-qa:01-acceptance-qa` | F | Recette d'acceptation : verrouille au plus un parcours nominal et les cas limites cités par les critères d'acceptation, les rejoue et filme chaque scénario comme preuve pour la revue. Les scénarios viennent **uniquement des critères**, jamais du code | ❌ ne pilote qu'un **navigateur** (via `playwright-cli`, un outil tiers) ; une app macOS native n'est pas testable ainsi. Pour CopyKit : XCUITest et la recette manuelle |
| `aidd-telemetry:00-init` | T | Active ou coupe la mesure des tokens pour un dépôt, avec ton consentement explicite ; nom ou anonymat ; effacement des données | ⚪ optionnel ; exige la CLI npm `@ai-driven-dev/cli` (non installée) |
| `aidd-telemetry:01-usage` | T | Répond à « combien de tokens a coûté telle période, tâche ou ticket », à partir de la mesure locale ; lecture seule | ⚪ seulement si la mesure est activée |

**Les hooks d'`aidd-telemetry`** : `session-start.cjs` et `catch-up.cjs` à chaque
démarrage de session, et `prompt-gate.cjs` **à chacun de tes prompts**. Ce
dernier peut bloquer un prompt pour te demander de déclarer une tâche. D'après
son code, il est **inerte** hors d'un dépôt où la mesure a été activée
(`aidd telemetry on`), ce qui n'est pas le cas de CopyKit. Rien n'est envoyé
nulle part : les données restent dans `~/.config/aidd/telemetry`.
`AIDD_TELEMETRY=0` désactive tout.

## Vérifier une installation

À refaire après chaque mise à jour : une mise à jour peut copier un plugin de
façon incomplète **sans aucun message d'erreur** (c'est arrivé deux fois le
2026-10-31 : les agents de `aidd-dev`, deux fichiers de `aidd-context`).

1. Mettre à jour : `claude plugin marketplace update aidd-framework`, puis
   `claude plugin update <plugin>@aidd-framework`.
2. Récupérer le dépôt officiel :
   `git clone --depth 1 https://github.com/ai-driven-dev/framework.git <dossier>`
   et la dernière version de chaque plugin :
   `gh release list -R ai-driven-dev/framework`.
3. Comparer chaque plugin installé au dépôt officiel :
   `diff -rq <dossier>/plugins/<plugin> ~/.claude/plugins/cache/aidd-framework/<plugin>/<version>`.
   Seuls les fichiers techniques `.in_use` et `.orphaned_at` peuvent différer.
4. Vérifier que chaque élément déclaré dans `.claude-plugin/plugin.json`
   (`skills`, `agents`) existe dans la copie installée.
5. En cas d'écart : `claude plugin uninstall <plugin>@aidd-framework`, puis
   `claude plugin install <plugin>@aidd-framework`, et refaire l'étape 3.

Résultat du 2026-10-31 : les 6 plugins installés sont à la dernière release
(v5.13.0, égale à la branche `main`) et identiques au dépôt officiel.

## Ce qui ne sert pas pour CopyKit

| Skill | Raison |
| --- | --- |
| `aidd-context:01-bootstrap` | pensé pour un SaaS ; la stack est déjà choisie (ADR 0001) |
| `aidd-vcs:00-repo-init` | le dépôt existe déjà |
| `aidd-dev:06-test` action `test-journey`, `aidd-dev:03-assert` facette frontend | testent dans un navigateur ; pour l'app : XCUITest |
| `aidd-orchestrator:00-async-dev` | plus tard, s'il y a un backlog d'issues GitHub et une CI |
| `aidd-ui:01-hello` | test de chargement d'un plugin alpha |
| `aidd-qa:01-acceptance-qa` | navigateur uniquement |
| `aidd-telemetry:*` | tant que la mesure des tokens n'est pas souhaitée |

## Points d'attention

1. **Préparer `coding-assertions.md` et `vcs.md`** pendant l'étape 0 (dans
   `vcs.md`, remplir aussi les lignes **Tickets** : GitHub Issues via `gh`, et
   **Hooks** : `protect-main.sh` bloque `main`). Sans eux,
   `03-assert` ne sait pas quoi lancer, et `01-commit` et `02-pull-request`
   appliquent leurs conventions par défaut au lieu des nôtres (branches
   `claude/*`, messages en anglais, PR draft).
2. **Confirmer les capacités `desktop`, `database` et `ui`** au moment du
   `setup` : la détection automatique vise surtout le web.
3. **Les skills `aidd-pm` écrivent dans `aidd_docs/`** : le brief et les
   stories vivent dans `aidd_docs/` comme toute la documentation du projet.
4. **Rien n'est écrit sans ton accord** dans `aidd-pm` et `aidd-vcs`, mais
   `02-implement` commite seul à chaque tâche, et `01-sdlc` en mode `auto` va
   jusqu'à la PR sans s'arrêter.
5. **`09-for-sure`** agit à ta place : à réserver à des tâches bien bornées.
