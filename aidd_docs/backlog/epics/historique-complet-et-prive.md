---
type: epic
status: proposed
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
goal: aidd_docs/product/copykit.md
order: 1
---

# Epic: Historique complet et privé

Avec CopyKit 1.0, un utilisateur de Mac ne perd plus jamais une copie : il la
retrouve et la recolle en un instant, sans que rien de confidentiel ne soit gardé.

## Context and Value

Garder un historique du presse-papiers impose aujourd'hui un compromis : Paste
est soigné mais fermé et en abonnement, Maccy est ouvert mais minimaliste,
Spotlight (macOS 26) ne garde que 7 jours au plus, sans épinglés. Cet epic porte
le premier pari du product brief : un historique beau, simple, rapide et privé,
gratuit et open source, qui remplace Paste au quotidien. Il s'adresse d'abord à
Yanis, puis à tous les utilisateurs de Mac, débutants compris, selon le principe
« simple par défaut, puissant sur demande ».

Les spikes de l'étape B ont rendu le cœur faisable : lecture du presse-papiers
en arrière-plan sans alerte sur macOS 27.2, recherche chiffrée sous les seuils,
copies du presse-papiers universel lisibles.

## Boundaries

- Includes: la capture de chaque copie, de tous les types et avec tous ses formats, sans dégradation
- Includes: les copies arrivées d'un autre appareil par le presse-papiers universel
- Includes: les catégories, la timeline, la recherche et les filtres
- Includes: le collage simple, en texte brut, et direct dans l'app active, avec un repli sans la permission Accessibilité
- Includes: épingler et désépingler, avec une section des épinglés
- Includes: la suppression d'une copie, avec annulation
- Includes: la durée de conservation, la limite de stockage, les copies volumineuses temporaires, le nettoyage automatique et les confirmations avant suppression
- Includes: la confidentialité complète (marqueurs, apps exclues, catégories exclues, pause de la capture) et le retour visuel et sonore
- Includes: le chiffrement de l'historique et la gestion de sa clé
- Includes: le bandeau de l'historique en bas de l'écran, l'icône dans la barre de menus, le raccourci global et le lancement à l'ouverture de session
- Includes: les raccourcis personnalisables dans les Réglages, avec la détection des conflits
- Includes: l'onboarding, les Réglages et la page « Permissions »
- Includes: les budgets de sobriété et de réactivité
- Excludes: les pinboards, le nom personnalisé d'une copie et le collage multiple (epic 3, tranche 1.1)
- Excludes: la synchronisation iCloud entre Mac (epic 4, tranche 1.2)
- Excludes: le téléchargement, l'installation et les mises à jour (epic 2)
- Excludes: les captures (V2) et la gestion des fenêtres (V3)
- Excludes: toute statistique d'usage

## Success Evidence

Yanis utilise CopyKit 1.0 quatre semaines d'affilée sans revenir à Paste, et
5 utilisateurs débutants l'installent et s'en servent sans aide grâce à
l'onboarding. Les tests de performance automatiques tiennent les budgets du
brainstorm (CPU au repos ≤ 0,1 %, mémoire ≤ 80 Mo, historique visible ≤ 100 ms
après le raccourci, recherche ≤ 50 ms pour 10 000 éléments et ≤ 150 ms pour
100 000, collage ≤ 150 ms). Les tests de confidentialité prouvent qu'aucun
élément confidentiel, temporaire ou venant d'une app exclue n'est jamais écrit
sur le disque, et qu'aucune copie n'y est écrite en clair.

## Dependencies and Unknowns

| Item | Kind | Handling |
| --- | --- | --- |
| Durée de conservation et limite de stockage par défaut | decision | tranché : 1 mois de conservation et 1 Go par défaut, limite réglable jusqu'à 10 Go ([brainstorm](../../tasks/2026_10/2026_10_31_copykit/brainstorm.md)) |
| Hors App Sandbox, chiffrement comme protection principale | decision | [ADR hors App Sandbox](../../memory/internal/decisions/hors-app-sandbox.md) |
| Lecture du presse-papiers sans alerte | dependency | [spike résolu](../spikes/alerte-confidentialite-presse-papiers.md) ; une future activation de l'alerte par Apple reste à surveiller |
| Copies du presse-papiers universel | dependency | [spike résolu](../spikes/presse-papiers-universel.md) |
| Index de recherche chiffré | dependency | [spike résolu](../spikes/chiffrement-et-recherche.md) |
| Ce que Time Machine restaure de la clé | spike | [gardé pour plus tard](../spikes/time-machine-et-trousseau.md) ; il ne change que le message après une restauration |
| Des débutants adopteront CopyKit s'il est simple par défaut | assumption | vérifiée par les 5 testeurs débutants |
