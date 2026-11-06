---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_appkit/brainstorm.md
related_to:
  - aidd_docs/product/appkit.md
---

# Spike: Mac de GitHub Actions

## Question

Les Mac fournis par GitHub Actions proposent-ils Xcode 27.1 et macOS 27, nécessaires pour construire et tester AppKit avec le SDK de macOS 27 ?

## Decision

Comment les tests tournent sur chaque PR, et sur quelle image.

## Bounds

- Evidence needed: la liste officielle des images macOS du dépôt `actions/runner-images` et les versions d'Xcode qu'elles contiennent.
- Stop when: on sait quelle image utiliser, ou qu'aucune ne convient encore.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| Liste officielle des images | [actions/runner-images](https://github.com/actions/runner-images) | Images macOS disponibles : macOS 26 (Apple silicon, étiquettes `macos-26` et `macos-latest`), macOS 15, et macOS 14 (dépréciée). Aucune image « macOS 27 ». Une image **`xcode-27`** (Apple silicon) existe, en préversion |
| Annonce de l'image Xcode 27 | [GitHub Changelog, 16 juillet 2026](https://github.blog/changelog/2026-07-16-xcode-27-runner-image-now-in-public-preview) | L'image `xcode-27` (et `xcode-27-xlarge`) est en préversion publique, uniquement sur Apple silicon. Chaque image suit une version majeure d'Xcode, et non une version de macOS |
| Contenu de l'image | [runner-images, xcode-27-arm64 du 31 août](https://github.com/actions/runner-images/releases/tag/xcode-27-arm64%2F20260831.0151), [du 7 septembre](https://github.com/actions/runner-images/releases/tag/xcode-27-arm64%2F20260907.0173) | La dernière liste lue contient Xcode 27.0 en bêta ; une image de septembre tourne sur macOS 27.0. Xcode 27.1 n'apparaît dans aucune source lue |

## Outcome

- Result: utiliser l'image **`xcode-27`** (Apple silicon) pour les tests de chaque PR. Elle fournit Xcode 27 et le SDK de macOS 27, mais elle est en préversion, et la présence d'Xcode 27.1 n'est pas confirmée. Les images `macos-26` ne conviennent pas, puisqu'elles n'ont pas le SDK de macOS 27. Un Mac personnel en « runner auto-hébergé » est exclu pour un dépôt public : du code de PR externe y tournerait.
- Confidence: moyenne (image en préversion, versions d'Xcode qui évoluent chaque semaine).
- Remaining uncertainty: la version exacte d'Xcode au moment de configurer les tests, et l'éventuel passage de l'image en disponibilité générale.

## Follow-up

- Au moment d'écrire le workflow de tests (étape E ou G), relire le README de l'image `xcode-27-arm64` et choisir explicitement la version d'Xcode avec `xcode-select`, au lieu de dépendre de celle par défaut.
- Mettre à jour la question ouverte correspondante du brainstorm.
