---
status: approved
date: 2026-10-31
---

# CopyKit

Une app de barre de menus macOS, open source, qui remplace Paste, CleanShot X et Swish par une seule app privée, rapide et sobre. Elle est d'abord faite pour Yanis, puis pour ceux qui la téléchargent.

## Clear

- Trois versions majeures, chacune livrée en 2 ou 3 tranches ; chaque tranche livre des fonctions complètes :
  - V1, presse-papiers : 1.0 l'historique de tous les types, la timeline, la recherche et les filtres, le collage simple et en texte brut, la barre de menus, le raccourci global et la confidentialité complète ; 1.1 les pinboards, le collage multiple, les raccourcis configurables avec gestion des conflits ; 1.2 la synchronisation iCloud entre Mac.
  - V2, captures : 2.0 les captures et les actions après capture, avec l'historique ; 2.1 l'annotation, les styles et l'OCR ; 2.2 la vidéo, les GIF et l'audio.
  - V3, fenêtres : 3.0 le mode clavier et le snapping ; 3.1 les gestes trackpad ; 3.2 le multi-fenêtres, les écrans et les Spaces.
- Inspiré des usages de Paste, CleanShot X et Swish, jamais de leur interface, de leur code ni de leurs assets.
- Mac uniquement : pas d'app iPhone pour l'instant.
- Distribution directe sur le site de Yanis et GitHub, app signée Developer ID et notarisée, pas d'App Store.
- Open source, avec des dons possibles sur le site ; pas de version payante.
- Données locales et privées : sans compte, sans serveur propriétaire, aucune donnée envoyée à un tiers ; la synchronisation iCloud se fait en privé, entre plusieurs Mac.
- Copies complètes : chaque copie est gardée avec tous ses formats, pour être recollée exactement comme l'original.
- Fichiers par référence : un fichier copié depuis le Finder se recolle comme une vraie copie de fichier, sans que son contenu soit dupliqué ; un fichier supprimé entre-temps est signalé « introuvable ».
- Aucun doublon dans CopyKit : recopier un contenu déjà présent remonte l'élément existant en tête de l'historique, avec la nouvelle date et la nouvelle app source.
- Jamais gardés : les éléments que les apps marquent comme confidentiels ou temporaires, et tout ce qu'excluent les règles de confidentialité.
- Durée de conservation au choix : 1 jour, 1 semaine, 1 mois, 3 mois, 6 mois ou « jamais ».
- Nettoyage automatique : les plus vieilles copies sont supprimées quand le plafond de stockage est atteint ou quand la durée de conservation est dépassée ; les éléments épinglés ne le sont jamais.
- Sobriété et réactivité : extrêmement peu de ressources en arrière-plan, réaction instantanée.
- Dépendances : 100 % Apple, avec une seule exception, la mise à jour automatique (Sparkle, sauf alternative plus moderne).
- Lignes rouges, la liste s'allongera : ne jamais garder un élément exclu, ne rien envoyer à un tiers, ne pas ralentir le Mac, ne pas trop consommer en arrière-plan, ne jamais demander une permission sans dire pourquoi.
- Signal de réussite de la V1 : CopyKit remplace vraiment Paste au quotidien, et tous ses tests passent.

## Open

- Limites par défaut : la durée de conservation par défaut et les limites de stockage (pistes : 1 Go par défaut, jusqu'à 10 Go).
- iCloud hors App Store : la synchronisation fonctionne-t-elle pour une app distribuée en Developer ID ?
- Outil de mise à jour : existe-t-il une alternative plus moderne que Sparkle, et comment la brancher en toute sécurité ?
- Critères de validation détaillés de chaque tranche : seuils de réactivité et de consommation, tests manuels.
