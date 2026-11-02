# Coding Assertions

The checks that must pass for code to count as done. Minimal, run after every change.

Les commandes passent par Portly (`portly temp '<commande>' --path <dépôt>` puis `portly wait <id>`). Avec Xcode ouvert, les outils MCP `BuildProject` et `RunSomeTests` font la même chose.

## Before commit

The fast gate.

| Order | Command | Checks |
| ----- | ------- | ------ |
| 1 | `xcodebuild -project CopyKit.xcodeproj -scheme CopyKit -destination 'platform=macOS' test -only-testing:CopyKitTests` | build Swift 6 sans erreur, tests unitaires |

## Before push

The heavier gate.

| Order | Command | Checks |
| ----- | ------- | ------ |
| 1 | `xcodebuild -project CopyKit.xcodeproj -scheme CopyKit -destination 'platform=macOS' test` | build, tests unitaires et tests d'interface XCUITest |

## Behavior

I fix is needed, spawn 1 agent per assertion to fix (e.g typechecking / tests / rules violated on category UI = 3 agents).
