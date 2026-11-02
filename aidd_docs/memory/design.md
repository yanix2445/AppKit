# Design

The visual language: the design system, tokens, and UI conventions. What it looks like, not how it is coded.

## System

- Natif d'abord : composants SwiftUI système, SF Symbols, styles de texte macOS, une seule couleur d'accent, Human Interface Guidelines d'Apple.
- Liquid Glass seulement sur la couche de contrôle (barres, panneaux), jamais sur le contenu.

## Tokens

- Aujourd'hui, seule la couleur d'accent existe : `CopyKit/Resources/Assets.xcassets/AccentColor.colorset`.
- Aucune valeur brute (couleur, rayon, espacement, durée) dans les vues : chaque valeur passe par un token Swift partagé.

## Accessibility

- Tout se fait au clavier ; chaque contrôle a un libellé VoiceOver ; le sens ne repose jamais sur la couleur seule ; Reduce Motion respecté.
- Audits avec les skills Apple `accessibility-voiceover-specialist` et `accessibility-sufficient-contrast-specialist`, et avec Accessibility Inspector.
