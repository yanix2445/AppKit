---
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
generated_at: 2026-10-31
---

# Shadow Areas Report

Source: `aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md`
Generated: `2026-10-31`

Total gaps: 18 | Blocker: 0 | Major: 14 | Minor: 4

---

## Gaps by Category

### unstated assumption

**[major]** Which minimum macOS version must CopyKit support for the people who download it?
> Mac uniquement : pas d'app iPhone pour l'instant.

**[major]** Is the clipboard history encrypted at rest on the Mac's disk?
> Données locales et privées : sans compte, sans serveur propriétaire, aucune donnée envoyée à un tiers

**[major]** Does CopyKit launch automatically at login so that no copy is missed after a restart?
> V1, presse-papiers : 1.0 l'historique de tous les types

### ambiguous term

**[major]** What background CPU, memory and energy thresholds define "extrêmement peu de ressources"?
> Sobriété et réactivité : extrêmement peu de ressources en arrière-plan, réaction instantanée.

**[major]** What maximum delay between the global shortcut and the visible history defines "réaction instantanée"?
> Sobriété et réactivité : extrêmement peu de ressources en arrière-plan, réaction instantanée.

**[major]** Which pasteboard types beyond text, links, images, files and colors belong to "tous les types" in V1.0?
> 1.0 l'historique de tous les types

**[major]** How should CopyKit recognise a bank card number that the source app did not mark as confidential?
> Jamais gardés : les éléments que les apps marquent comme confidentiels ou temporaires, et tout ce qu'excluent les règles de confidentialité.

**[minor]** Which rules make up the "confidentialité complète" delivered in V1.0?
> la barre de menus, le raccourci global et la confidentialité complète

### missing edge case

**[major]** Does copying the same text with different formatting count as a duplicate?
> Aucun doublon dans CopyKit : recopier un contenu déjà présent remonte l'élément existant en tête de l'historique

**[major]** What happens when a single copied item is larger than the whole storage limit?
> Nettoyage automatique : les plus vieilles copies sont supprimées quand le plafond de stockage est atteint

**[major]** What happens when pinned items alone exceed the storage limit?
> les éléments épinglés ne le sont jamais.

**[major]** What happens to existing items when the user lowers the storage limit or the retention period?
> Durée de conservation au choix : 1 jour, 1 semaine, 1 mois, 3 mois, 6 mois ou « jamais ».

### missing actor

**[minor]** Who reviews and accepts contributions from outside contributors to the open source repository?
> Open source, avec des dons possibles sur le site ; pas de version payante.

### missing failure mode

**[major]** What does CopyKit do when the user refuses the Accessibility permission needed for direct paste?
> le collage simple et en texte brut

**[major]** What does CopyKit do when iCloud is signed out or the iCloud storage quota is full?
> 1.2 la synchronisation iCloud entre Mac.

**[major]** How is a conflict resolved when one Mac deletes an item that another Mac pins?
> 1.2 la synchronisation iCloud entre Mac.

### missing acceptance criterion

**[minor]** How will "inspiré des usages, jamais de leur interface" be checked before a release?
> Inspiré des usages de Paste, CleanShot X et Swish, jamais de leur interface, de leur code ni de leurs assets.

### missing dependency

**[minor]** Where are the downloads and the update feed hosted: the website, GitHub Releases, or both?
> Distribution directe sur le site de Yanis et GitHub, app signée Developer ID et notarisée, pas d'App Store.
