---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
related_to:
  - aidd_docs/product/copykit.md
---

# Spike: alerte de confidentialité du presse-papiers

## Question

Sur macOS 26 et 27, que voit l'utilisateur quand une app comme CopyKit lit le presse-papiers général sans action de sa part, et comment l'app obtient-elle un accord durable ?

## Decision

La faisabilité du cœur de CopyKit (capter chaque copie en arrière-plan) et le parcours de permission de l'onboarding.

## Bounds

- Evidence needed: le comportement observé sur macOS 27 (valeur de `NSPasteboard.accessBehavior`, apparition ou non d'une alerte, réglage correspondant dans les Réglages Système) et le comportement documenté sur macOS 26.
- Stop when: on sait si une lecture en arrière-plan déclenche une alerte sur macOS 27 et comment l'utilisateur autorise durablement l'app.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| Recherche documentaire | [MacRumors (mai 2025)](https://www.macrumors.com/2025/05/12/apple-mac-apps-clipboard-change/), [Michael Tsai](https://mjtsai.com/blog/2025/05/12/pasteboard-privacy-preview-in-macos-15-4), [Apple, `AccessBehavior.default`](https://developer.apple.com/documentation/appkit/nspasteboard/accessbehavior-swift.enum/default.md), [Clipsody, PR #15](https://github.com/tillackt/clipsody/pull/15) | Apple a annoncé en 2025 une alerte quand une app lit le presse-papiers général sans action de collage de l'utilisateur, testable depuis macOS 15.4 comme préversion pour développeurs. La documentation dit que le presse-papiers général d'une app vaut `.default` jusqu'à la première alerte, puis `.ask`. D'après Clipsody, macOS 27.2 retire l'interrupteur de la préversion, sans confirmer le comportement par défaut |
| Essai réel sur macOS 27.2 (build 26B123) : une app AppKit jetable, signée ad hoc, lancée par `open`, qui lit `accessBehavior` puis le presse-papiers au lancement et à chaque copie, en ne journalisant que les types et les longueurs | Journal de l'essai, 2 novembre 2026 | Au lancement, sans aucune action de l'utilisateur : `accessBehavior = alwaysAllow`, lecture du texte en moins d'1 ms, aucune alerte |
| Même essai, trois copies faites par Yanis en arrière-plan (texte depuis Chrome, texte depuis une app WebKit, PDF depuis le Finder) | Journal de l'essai et retour de Yanis | Les trois copies sont captées en moins d'1 ms chacune, `accessBehavior` reste `alwaysAllow`, aucune alerte n'est apparue |

## Outcome

- Result: sur macOS 27.2, une app qui surveille le presse-papiers le lit en arrière-plan sans alerte : macOS lui attribue d'emblée `alwaysAllow`. Le cœur de CopyKit est faisable tel que décidé. Sur macOS 26, l'alerte n'existe qu'en préversion pour développeurs, désactivée par défaut. Pour un accord durable, si Apple active l'alerte, l'utilisateur choisit le comportement de l'app dans les Réglages Système, et `accessBehavior` permet à l'app de lire ce choix.
- Confidence: bonne pour macOS 27.2 (essai réel, reproduit deux fois) ; moyenne pour macOS 26 (sources secondaires) et pour la suite (Apple peut activer l'alerte dans une version future).
- Remaining uncertainty: le comportement d'une build signée Developer ID et lancée depuis le Finder ; macOS 26 non testé sur une vraie machine ; l'activation future de l'alerte par Apple.

## Follow-up

- CopyKit lit `NSPasteboard.general.accessBehavior` au lancement et à l'ouverture de ses Réglages : `.alwaysAllow`, il capte sans rien demander ; `.default`, l'onboarding explique pourquoi CopyKit lit le presse-papiers juste avant la première lecture, pour que l'alerte, si elle apparaît, arrive au moment où l'utilisateur s'y attend ; `.ask` ou `.alwaysDeny`, CopyKit explique ce qui ne marche pas et ouvre le bon réglage. La page « Permissions » des Réglages montre cet état.
- Observé en passant, pour la règle des doublons : Chrome ajoute `org.chromium.internal.source-rfh-token` et `org.chromium.source-url`, et WebKit ajoute `com.apple.WebKit.custom-pasteboard-data`. Ce sont des candidats à la liste des formats qui varient à chaque copie. Une copie du Finder porte `public.file-url` et `com.apple.finder.noderef`. Aucune des trois copies ne portait le marqueur `org.nspasteboard.source`.
- Mettre à jour la question ouverte correspondante du brainstorm.
