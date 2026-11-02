---
type: epic
status: proposed
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
goal: aidd_docs/product/copykit.md
order: 2
---

# Epic: Installer et mettre à jour CopyKit en confiance

N'importe qui télécharge CopyKit sur le site de Yanis ou sur GitHub, l'installe
sans alerte de sécurité de macOS, reçoit ses mises à jour signées, et peut
contribuer au projet dans un cadre clair.

## Context and Value

CopyKit voit tout ce que l'utilisateur copie : la confiance dans le binaire et
dans ses mises à jour fait partie du produit. Distribué hors App Store, gratuit
et open source, CopyKit doit être signé, notarisé et mis à jour sans qu'une
fausse mise à jour puisse passer. Le dépôt public doit aussi pouvoir recevoir
des contributions sans que Yanis perde le contrôle de `main` ni des releases.

## Boundaries

- Includes: les trois formats signés Developer ID et notarisés (`.dmg` mis en avant, `.zip` avec `CopyKit.app`, `.pkg` signé Developer ID Installer), avec leurs empreintes SHA-256, dans des releases GitHub immuables
- Includes: le bouton de téléchargement du site, qui pointe vers les liens stables de GitHub
- Includes: les mises à jour automatiques par Sparkle 2, avec le flux sur le domaine de Yanis servi par Vercel, la signature Developer ID et la notarisation comme chaîne de confiance principale, et Ed25519 en seconde couche
- Includes: le workflow de release lancé par un tag de Yanis, avec la signature et la notarisation dans un environnement GitHub protégé
- Includes: les tests de chaque PR sur l'image GitHub `xcode-27`
- Includes: le comptage anonyme des vérifications de mises à jour, sans conserver les adresses IP
- Includes: la politique de confidentialité en français et en anglais, sur le site et dans les Réglages
- Includes: la liste des composants (SBOM) publiée avec chaque release, et la durée de support annoncée
- Includes: le cadre des contributions : `CONTRIBUTING.md`, `SECURITY.md` avec le signalement privé, code de conduite, formulaires d'issue et modèle de PR d'après AIDD, workflow de vérification des PR, Discussions, étiquettes et `FUNDING.yml`
- Excludes: l'installation par Homebrew (plus tard, quand l'app sera connue)
- Excludes: l'App Store
- Excludes: toute statistique d'usage dans l'app
- Excludes: la protection de `main` et le nettoyage des branches, déjà en place

## Success Evidence

Sur un Mac qui n'a jamais vu CopyKit, le `.dmg` téléchargé depuis le site
s'installe sans alerte de Gatekeeper. Une version installée détecte, télécharge
et installe la suivante d'elle-même, et refuse une mise à jour dont la signature
est fausse. Chaque PR lance les tests sur GitHub, et une PR externe de test
suit tout le parcours prévu (formulaire, vérifications, tests après accord,
merge par Yanis).

## Dependencies and Unknowns

| Item | Kind | Handling |
| --- | --- | --- |
| Certificats Developer ID Application et Developer ID Installer, et accès à la notarisation | dependency | à créer sur le compte Apple Developer de Yanis |
| Sous-domaine exact du flux de mises à jour (piste : `copykit.yanis-harrat.com`) | decision | à trancher par Yanis |
| Sparkle 2 et l'architecture `arm64e` d'Enhanced Security | assumption | à vérifier à l'intégration ; au besoin, `ENABLE_POINTER_AUTHENTICATION = NO` sur la cible qui le lie ([décisions de sécurité](../../memory/internal/xcode-security-settings.md)) |
| Choix de Sparkle 2 et statut d'Ed25519 pour l'ANSSI | dependency | [spike résolu](../spikes/outil-de-mise-a-jour.md) ; statut d'EdDSA dans le guide 2026 à vérifier avant la release |
| Image `xcode-27` en préversion et présence d'Xcode 27.1 | dependency | [spike résolu](../spikes/mac-github-actions.md) ; version à fixer au moment d'écrire le workflow |
| Cyber Resilience Act | dependency | [spike résolu](../spikes/cyber-resilience-act.md) ; relecture juridique avant la première release publique |
| Marque « CopyKit » | dependency | [spike résolu](../spikes/nom-copykit.md) ; bases de l'EUIPO, de l'INPI et de l'USPTO à consulter avant la release |
