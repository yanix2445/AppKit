---
source: aidd_docs/backlog/stories
generated_at: 2026-11-03
status: clean
---

# Shadow Areas Report

Source: `aidd_docs/backlog/stories`
Generated: `2026-11-03`

Total gaps: 1 | Blocker: 0 | Major: 0 | Minor: 1

---

## Warnings

- The source is a folder of 39 Markdown stories, scanned as one artifact; each snippet comes from the story named in its quote.

---

## Gaps by Category

### unstated assumption

#### Closed

**[major]** Which languages does the 1.0 interface ship in, and which work delivers the English translation of the French source texts?
> lire-la-politique-de-confidentialite.md : Une politique de confidentialité courte, en français et en anglais

### ambiguous term

#### Closed

**[major]** How does the user pick "un autre raccourci" in 1.0, when configurable shortcuts only arrive in 1.1?
> ouvrir-le-bandeau-au-raccourci-global.md : AppKit le dit clairement et propose un autre raccourci

**[major]** Does a copy count as a "Lien" only when the whole copy is one URL, or also when a longer text contains a URL?
> retrouver-mes-textes-enrichis-liens-et-couleurs.md : Un lien, même copié comme simple texte, s'affiche dans la catégorie Lien

**[major]** Must a search result contain every word of the query, or any one of them?
> chercher-dans-mon-historique.md : Chaque mot de la requête est cherché séparément

**[minor]** Which setting lets the user keep copies marked as generated automatically?
> ne-jamais-garder-une-copie-confidentielle.md : n'est pas gardée, par défaut

**[minor]** Are the kept and discarded sounds on or off by default, and which system sounds are they?
> savoir-si-une-copie-est-gardee-ou-ecartee.md : Une copie écartée joue un son, une copie gardée en joue un autre

**[minor]** Which functions get a short contextual explanation on first use?
> decouvrir-appkit-avec-l-onboarding.md : Des explications courtes apparaissent lors des premières utilisations d'une fonction

### missing edge case

#### Closed

**[major]** Is a deleted copy erased from the disk immediately, or only once ⌘Z can no longer bring it back?
> supprimer-une-copie.md : ⌘Z annule la dernière suppression tant que le bandeau reste ouvert

**[minor]** Does a pause "jusqu'à réactivation" survive a restart of AppKit or of the Mac?
> mettre-la-capture-en-pause.md : 5 minutes, 1 heure, jusqu'à réactivation, ou ignorer la prochaine copie

**[minor]** What does ⇧Entrée do when the Accessibility permission for direct paste is missing?
> coller-en-texte-brut.md : ⇧Entrée sur une copie la colle en texte brut

**[minor]** What happens when the release tag does not match the app's version number?
> publier-un-dmg-signe-en-posant-un-tag.md : Poser un tag `vX.Y.Z` sur `main` lance le workflow de release

#### Newly Introduced

**[minor]** What happens when ⇧⌘V and all three backup shortcuts are already taken by other apps?
> ouvrir-le-bandeau-au-raccourci-global.md : propose un raccourci de secours parmi ⇧⌘C, ⌥⌘V et ⌃⌘V

### missing failure mode

#### Closed

**[major]** How can the PR check comment on a pull request from a fork, whose token is read-only, without the risky `pull_request_target` trigger?
> etre-guide-quand-ma-pr-est-incomplete.md : reçoit un commentaire qui dit exactement ce qui manque

**[minor]** What happens when the active app has no editable field to paste into?
> coller-directement-dans-l-app-active.md : la colle dans l'app active, en 150 ms au plus

### missing acceptance criterion

#### Closed

**[major]** Which check proves that AppKit runs on macOS 26, when the GitHub image only provides macOS 27?
> voir-les-tests-tourner-sur-chaque-pr.md : Chaque PR lance le build, les tests unitaires et les tests d'interface sur l'image GitHub `xcode-27`

### missing dependency

#### Closed

**[minor]** Which dedicated email address receives the security reports?
> signaler-une-faille-en-prive.md : une adresse e-mail dédiée sert de secours
