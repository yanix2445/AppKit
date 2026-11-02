---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_copykit/brainstorm.md
related_to:
  - aidd_docs/product/copykit.md
---

# Spike: App Sandbox

## Question

Quelles fonctions de la V1 restent possibles si CopyKit active l'App Sandbox : lecture du presse-papiers, collage direct dans l'app active, raccourci global, lancement à l'ouverture de session, fichiers copiés depuis le Finder, Trousseau, et protection des fichiers de l'historique contre les autres apps ?

## Decision

L'ADR sur le sandbox, et donc ce qui justifie le chiffrement de l'historique.

## Bounds

- Evidence needed: pour chaque fonction, une source Apple (documentation, forums des développeurs) ou un essai, qui la classe possible ou impossible en sandbox.
- Stop when: chaque fonction de la V1 est classée.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| Essai réel, macOS 27.2 : une app AppKit jetable **sandboxée** (signée ad hoc avec `com.apple.security.app-sandbox`), qui lit le presse-papiers, tente de lire les fichiers copiés et d'en créer un bookmark sécurisé | Journal de l'essai, 2 novembre 2026, et retour de Yanis | Le presse-papiers se lit sans alerte. Un PDF copié depuis le Finder déclenche une demande d'autorisation de macOS (accès au dossier où il se trouve), puis devient lisible, et un bookmark sécurisé permet de le relire plus tard. Une **photo copiée sur l'iPhone** (presse-papiers universel) est **illisible** en sandbox, et aucun bookmark n'est possible |
| Même photo lue hors sandbox | Essai du spike sur le presse-papiers universel | Hors sandbox, le fichier temporaire de la photo est lisible (3,4 Mo) |
| Collage direct | [Forums Apple, gestionnaire refusé (2.4.5)](https://developer.apple.com/forums/thread/820594) | Envoyer ⌘V par `CGEvent.post` passe par l'autorisation « poster des événements » (`CGRequestPostEventAccess`), compatible avec le sandbox d'après un ingénieur d'Apple ; c'est la revue de l'App Store qui le refuse, sans objet ici |
| Fonctions d'Accessibilité, nécessaires pour la gestion des fenêtres de la V3 | [Forums Apple, fil 836644](https://developer.apple.com/forums/thread/836644), [Blake Crosley](https://blakecrosley.com/fr/blog/window-manager-mac-app-store-sandbox) | Un ingénieur d'Apple rappelle que les API d'Accessibilité ne sont pas prises en charge en sandbox : déplacer la fenêtre d'une autre app échoue même avec l'autorisation. Aucun entitlement ne le débloque |
| Protection des fichiers de l'historique | [CVE-2023-42929 (jhftss)](https://jhftss.github.io/CVE-2023-42929-Why-Do-We-Need-The-App-Container-Protection), [mysk, CVE-2026-28910](https://mysk.blog/2026/05/19/cve-2026-28910/) | Depuis macOS 14, le conteneur d'une app sandboxée est protégé par une autorisation « données d'autres apps » : les autres apps, même hors sandbox, ne le lisent pas librement. Hors sandbox, les fichiers rangés dans `~/Library/Application Support` sont lisibles par les autres apps de l'utilisateur qui ne sont pas sandboxées |

## Outcome

- Result: le sandbox est **incompatible avec le produit décidé**. La V1 y perdrait la garde des photos et fichiers arrivés par le presse-papiers universel, et la V3 (gestion des fenêtres) y est impossible, puisque les API d'Accessibilité n'y fonctionnent pas. Le reste de la V1 resterait possible en sandbox : lecture du presse-papiers, collage direct par `CGEvent`, fichiers du Finder avec bookmark sécurisé, Trousseau. Sans sandbox, les fichiers de l'historique ne bénéficient pas de la protection des conteneurs : le chiffrement de l'historique (AES-256-GCM, clé dans le Trousseau) devient la protection principale, ce qui le justifie pleinement. Le raccourci global et le lancement à l'ouverture de session n'ont pas été testés ; ils fonctionnent hors sandbox et ne pèsent donc pas sur la décision.
- Confidence: bonne (essais réels sur macOS 27.2 et réponses d'ingénieurs d'Apple).
- Remaining uncertainty: le texte exact de la demande d'autorisation vue pour le PDF ; une build Developer ID signée au lieu d'une signature ad hoc.

## Follow-up

- Écrire l'ADR : CopyKit hors App Sandbox, avec le Hardened Runtime, la signature Developer ID et la notarisation, et le chiffrement de l'historique comme protection principale.
- La demande d'autorisation d'accès aux dossiers protégés (Bureau, Documents, Téléchargements) concerne aussi une app hors sandbox quand elle lit un fichier : l'onboarding doit l'expliquer avant la première lecture d'un fichier copié (aperçu, envoi aux autres Mac).
- Mettre à jour la question ouverte du brainstorm sur les fichiers d'une app hors sandbox.
