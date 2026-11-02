# Desktop

The desktop app: framework, native access, and packaging.

## Framework

- Natif : SwiftUI, avec des ponts AppKit (`NSViewRepresentable`, `NSHostingView`) seulement là où SwiftUI ne suffit pas ; point d'entrée `CopyKit/App/CopyKitApp.swift`.
- Cible macOS 27.

## Native access

- App Sandbox et Hardened Runtime activés. L'App Sandbox bloque l'Accessibility (coller dans d'autres apps, raccourcis système) : la décision de le garder ou non se prend à l'étape B, dans un ADR.
- Toute permission se demande au moment où elle sert, avec une phrase qui dit ce qui ne marche pas sans elle.

## Build and release

- Signature automatique avec l'équipe Apple Developer du projet : macOS garde les autorisations d'un build à l'autre.
- Build et tests par Xcode, `xcodebuild` ou le serveur MCP `xcode` ; aucune chaîne de distribution n'est encore en place.
