# Design

The visual language: the design system, tokens, and UI conventions. What it looks like, not how it is coded.

## System

- Natif d'abord : composants SwiftUI système, SF Symbols, styles de texte macOS, une seule couleur d'accent, Human Interface Guidelines d'Apple.
- Liquid Glass seulement sur la couche de contrôle (barres, panneaux), jamais sur le contenu.

## Tokens

- Les maquettes font foi : fichier Figma [Appkit](https://www.figma.com/design/KXcvgnvBbi7VGSL9WmoiSh/Appkit), pages Icon, Composant et Ecrant, chaque écran en clair et en sombre.
- Les tokens y sont des variables Figma, en deux modes (Clair, Sombre) : `color/*`, `space/*` (2, 4, 8, 12, 16, 24) et `radius/*` (contrôle 8, menu 12, carte 14, groupe 20, bandeau 32).
- En code, ils deviennent `AppKit/Shared/Design/` (`Spacing`, `CornerRadius`, `AppColor`, `Motion`), créés avec leur premier usage.
- Les maquettes sont composées en Inter faute de SF Pro dans Figma : l'app utilise les polices système.
- Aucune valeur brute (couleur, rayon, espacement, durée) dans les vues : chaque valeur passe par un token Swift partagé.

## Components

- Le bandeau : un panneau en bas de l'écran, en matériau translucide, avec une barre d'outils (recherche, filtres de catégorie, aide clavier) au-dessus d'une rangée de cartes.
- La carte : 196 × 176, avec l'en-tête (type, date, icône de l'app source), l'aperçu du contenu et une ligne de métadonnées.

## Voice

- L'app vouvoie, partout : interface, messages, alertes, onboarding et notifications (« Copié · faites ⌘V »).
- Phrases courtes qui disent quoi faire ; une permission dit toujours ce qui ne marche pas sans elle.

## Accessibility

- Tout se fait au clavier ; chaque contrôle a un libellé VoiceOver ; le sens ne repose jamais sur la couleur seule ; Reduce Motion respecté.
- Audits avec les skills Apple `accessibility-voiceover-specialist` et `accessibility-sufficient-contrast-specialist`, et avec Accessibility Inspector.
