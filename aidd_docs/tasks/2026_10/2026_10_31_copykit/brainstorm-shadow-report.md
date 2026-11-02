---
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
generated_at: 2026-11-02
---

# Shadow Areas Report

Source: `aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md`
Generated: `2026-11-02`

Total gaps: 7 | Blocker: 0 | Major: 3 | Minor: 4

---

## Gaps by Category

### unstated assumption

#### Closed

**[major]** Which minimum macOS version must CopyKit support for the people who download it?
> Mac uniquement : pas d'app iPhone pour l'instant.

**[major]** Is the clipboard history encrypted at rest on the Mac's disk?
> Données locales et privées : sans compte, sans serveur propriétaire, aucune donnée envoyée à un tiers

**[major]** Does CopyKit launch automatically at login so that no copy is missed after a restart?
> V1, presse-papiers : 1.0 l'historique de tous les types

### ambiguous term

#### Closed

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

#### Newly Introduced

**[minor]** What file size counts as "très gros" and exempts a copy from the 50 ms processing limit?
> une nouvelle copie est traitée en ≤ 50 ms (hors très gros fichiers) sans geler l'interface

**[minor]** Which password managers count as "les gestionnaires de mots de passe installés" excluded by default?
> (d) apps exclues, par défaut l'app Mots de passe, Trousseaux d'accès et les gestionnaires de mots de passe installés, liste modifiable

### missing edge case

#### Closed

**[major]** Does copying the same text with different formatting count as a duplicate?
> Aucun doublon dans CopyKit : recopier un contenu déjà présent remonte l'élément existant en tête de l'historique

**[major]** What happens when a single copied item is larger than the whole storage limit?
> Nettoyage automatique : les plus vieilles copies sont supprimées quand le plafond de stockage est atteint

**[major]** What happens when pinned items alone exceed the storage limit?
> les éléments épinglés ne le sont jamais.

**[major]** What happens to existing items when the user lowers the storage limit or the retention period?
> Durée de conservation au choix : 1 jour, 1 semaine, 1 mois, 3 mois, 6 mois ou « jamais ».

#### Newly Introduced

**[major]** Does a pinned item stay pinned when the same content is copied again and the newer copy replaces it?
> La copie la plus récente remplace l'ancienne et remonte en tête, avec sa date et son app source.

**[major]** What does another Mac show for a Finder file copied by reference when the file exists only on the original Mac?
> Fichiers par référence : un fichier copié depuis le Finder se recolle comme une vraie copie de fichier, sans que son contenu soit dupliqué

**[minor]** Does the deletion confirmation announce the impact on every Mac when the synchronized storage limit is lowered on one of them?
> La limite de stockage et la durée de conservation sont les mêmes sur tous les Mac (réglage synchronisé)

### missing actor

#### Closed

**[minor]** Who reviews and accepts contributions from outside contributors to the open source repository?
> Open source, avec des dons possibles sur le site ; pas de version payante.

#### Newly Introduced

**[minor]** Who receives and handles security vulnerability reports sent privately about CopyKit?
> Contributions, ouvertes à tous et sans frustration, sous le contrôle de Yanis

### missing failure mode

#### Closed

**[major]** What does CopyKit do when the user refuses the Accessibility permission needed for direct paste?
> le collage simple et en texte brut

**[major]** What does CopyKit do when iCloud is signed out or the iCloud storage quota is full?
> 1.2 la synchronisation iCloud entre Mac.

**[major]** How is a conflict resolved when one Mac deletes an item that another Mac pins?
> 1.2 la synchronisation iCloud entre Mac.

#### Newly Introduced

**[major]** What happens to the encrypted history when its Keychain key is missing, for example after restoring a backup or migrating to a new Mac?
> avec une clé gardée dans le Trousseau et accessible seulement par CopyKit ; il reste illisible pour les autres apps et dans les sauvegardes.

### missing acceptance criterion

#### Closed

**[minor]** How will "inspiré des usages, jamais de leur interface" be checked before a release?
> Inspiré des usages de Paste, CleanShot X et Swish, jamais de leur interface, de leur code ni de leurs assets.

### missing dependency

#### Closed

**[minor]** Where are the downloads and the update feed hosted: the website, GitHub Releases, or both?
> Distribution directe sur le site de Yanis et GitHub, app signée Developer ID et notarisée, pas d'App Store.
