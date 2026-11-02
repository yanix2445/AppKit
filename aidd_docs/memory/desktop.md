# Desktop

The desktop app: framework, native access, and packaging.

## Framework

- Natif : SwiftUI, avec des ponts AppKit (`NSViewRepresentable`, `NSHostingView`) seulement là où SwiftUI ne suffit pas ; point d'entrée `CopyKit/App/CopyKitApp.swift`.
- Cible macOS 27.

## Native access

- Hors App Sandbox, Hardened Runtime activé, signature Developer ID et notarisation : voir `aidd_docs/memory/internal/decisions/hors-app-sandbox.md`. Le réglage `ENABLE_APP_SANDBOX` du projet vaut encore `YES`, en écart connu avec l'ADR.
- Sans conteneur, la protection des données repose sur le chiffrement de l'historique : jamais de clé ni de copie en clair sur le disque.
- Toute permission se demande au moment où elle sert, avec une phrase qui dit ce qui ne marche pas sans elle.

## Build and release

- Signature automatique avec l'équipe Apple Developer du projet : macOS garde les autorisations d'un build à l'autre.
- Build et tests par Xcode, `xcodebuild` ou le serveur MCP `xcode` ; aucune chaîne de distribution n'est encore en place.
