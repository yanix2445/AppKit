---
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
generated_at: 2026-11-02
status: clean
---

# Shadow Areas Report

Source: `aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md`
Generated: `2026-11-02`

Total gaps: 2 | Blocker: 0 | Major: 0 | Minor: 2

---

## Gaps by Category

### ambiguous term

#### Closed

**[minor]** What file size counts as "très gros" and exempts a copy from the 50 ms processing limit?
> une nouvelle copie est traitée en ≤ 50 ms (hors très gros fichiers) sans geler l'interface

**[minor]** Which password managers count as "les gestionnaires de mots de passe installés" excluded by default?
> (d) apps exclues, par défaut l'app Mots de passe, Trousseaux d'accès et les gestionnaires de mots de passe installés, liste modifiable

#### Newly Introduced

**[minor]** Does a Finder file kept by reference count as a "copie volumineuse" when the file itself exceeds the threshold?
> Copies volumineuses : une copie qui dépasse le seuil « volumineux » (réglable, par défaut 10 % de la limite de stockage) est gardée à part

### missing edge case

#### Closed

**[major]** Does a pinned item stay pinned when the same content is copied again and the newer copy replaces it?
> La copie la plus récente remplace l'ancienne et remonte en tête, avec sa date et son app source.

**[major]** What does another Mac show for a Finder file copied by reference when the file exists only on the original Mac?
> Fichiers par référence : un fichier copié depuis le Finder se recolle comme une vraie copie de fichier, sans que son contenu soit dupliqué

**[minor]** Does the deletion confirmation announce the impact on every Mac when the synchronized storage limit is lowered on one of them?
> La limite de stockage et la durée de conservation sont les mêmes sur tous les Mac (réglage synchronisé)

#### Newly Introduced

**[minor]** What happens when the user pastes a copy that is visible in the history but whose processing is not finished yet?
> une nouvelle copie, quelle que soit sa taille, apparaît dans l'historique en ≤ 50 ms, et son traitement complet (empreinte, chiffrement, écriture, vignette) se fait toujours le plus vite possible, en arrière-plan

### missing actor

#### Closed

**[minor]** Who receives and handles security vulnerability reports sent privately about CopyKit?
> Contributions, ouvertes à tous et sans frustration, sous le contrôle de Yanis

### missing failure mode

#### Closed

**[major]** What happens to the encrypted history when its Keychain key is missing, for example after restoring a backup or migrating to a new Mac?
> avec une clé gardée dans le Trousseau et accessible seulement par CopyKit ; il reste illisible pour les autres apps et dans les sauvegardes.
