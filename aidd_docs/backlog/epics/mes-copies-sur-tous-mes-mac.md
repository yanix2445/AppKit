---
type: epic
status: proposed
source: aidd_docs/tasks/2026_10/2026_10_31_appkit/brainstorm.md
goal: aidd_docs/product/appkit.md
depends_on:
  - aidd_docs/backlog/epics/historique-complet-et-prive.md
order: 4
issue: "#12"
---

# Epic: Mes copies sur tous mes Mac

Avec AppKit 1.2, une copie faite sur un Mac est disponible sur les autres Mac
de l'utilisateur, en privé par son iCloud, sans jamais mettre en danger
l'historique local.

## Context and Value

Yanis travaille sur plusieurs Mac. Le presse-papiers universel d'Apple ne
transmet que la dernière copie, brièvement et à moins de 10 mètres ; Paste
synchronise, mais fermé et en abonnement ; Maccy ne synchronise pas. Cet epic
apporte la synchronisation durable, privée et chiffrée, en gardant l'historique
local comme référence.

## Boundaries

- Includes: la synchronisation par la base privée iCloud de l'utilisateur, contenu dans des champs chiffrés, désactivée par défaut et activable dans les Réglages
- Includes: l'historique local d'abord : sans compte, compte indisponible, iCloud plein ou déconnexion, l'historique local reste entier et la synchronisation se met en pause
- Includes: la demande avant d'envoyer l'historique vers un autre compte iCloud
- Includes: les conflits, où l'épinglé gagne, avec les suppressions et les limites appliquées sur tous les Mac
- Includes: le contenu des fichiers copiés, envoyé jusqu'au seuil « volumineux », et le badge du Mac d'origine au-delà
- Includes: une clé de chiffrement propre à chaque Mac, sans partage de clé
- Excludes: les copies volumineuses temporaires, jamais synchronisées
- Excludes: l'iPhone et l'iPad
- Excludes: tout serveur autre que l'iCloud privé de l'utilisateur

## Success Evidence

Sur les Mac de Yanis, une copie faite sur l'un apparaît sur l'autre, y compris
un fichier copié depuis le Finder. Une déconnexion d'iCloud laisse l'historique
entier, un iCloud plein met l'envoi en pause sans rien perdre, et un élément
épinglé sur un Mac n'est jamais effacé par une suppression venue de l'autre.
Ces cas sont couverts par des tests automatiques.

## Dependencies and Unknowns

| Item | Kind | Handling |
| --- | --- | --- |
| Historique complet et privé | dependency | `depends_on` |
| CloudKit pour une app Developer ID | dependency | [spike résolu](../spikes/icloud-developer-id.md) ; premier essai signé au début de la tranche |
| `CKSyncEngine` plutôt que la synchronisation automatique de SwiftData | decision | piste du brainstorm, à confirmer à la conception (étape D) |
| Délai acceptable entre une copie sur un Mac et son arrivée sur l'autre | decision | à trancher par Yanis au découpage de la tranche 1.2 |
| Profil de provisionnement Developer ID avec iCloud | dependency | à créer sur le compte Apple Developer de Yanis ; son expiration empêcherait l'app de se lancer |
