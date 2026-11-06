# Desktop

The desktop app: framework, native access, and packaging.

## Framework

- Natif : SwiftUI, avec des ponts vers le framework AppKit d'Apple (`NSViewRepresentable`, `NSHostingView`) seulement là où SwiftUI ne suffit pas ; point d'entrée `AppKit/App/AppKitApp.swift`.
- SDK de macOS 27, compatible macOS 26 (`MACOSX_DEPLOYMENT_TARGET = 26.0` sur les trois cibles), Mac Apple silicon seulement.

## Native access

- Hors App Sandbox, Hardened Runtime activé, signature Developer ID et notarisation : voir `aidd_docs/memory/internal/decisions/hors-app-sandbox.md`.- Sans conteneur, la protection des données repose sur le chiffrement de l'historique : jamais de clé ni de copie en clair sur le disque.
- Enhanced Security activée au niveau du projet : l'app se construit en `arm64e` (authentification des pointeurs), avec les entitlements « hardened-process » de `AppKit/AppKit.entitlements` et le marquage mémoire matériel en mode souple. Chaque décision de sécurité est tracée dans `aidd_docs/memory/internal/xcode-security-settings.md`.
- Toute permission se demande au moment où elle sert, avec une phrase qui dit ce qui ne marche pas sans elle.

## Build and release

- Signature automatique avec l'équipe Apple Developer du projet : macOS garde les autorisations d'un build à l'autre.
- Build et tests par Xcode, `xcodebuild` ou le serveur MCP `xcode` ; aucune chaîne de distribution n'est encore en place.
