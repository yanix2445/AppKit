---
type: story
status: proposed
parent: aidd_docs/backlog/epics/historique-complet-et-prive.md
depends_on:
  - aidd_docs/backlog/stories/ne-jamais-garder-une-copie-confidentielle.md
order: 4
---

# Story: Garder mon historique après un redémarrage, chiffré

**As** un utilisateur de Mac
**I want** que mon historique soit gardé quand je quitte CopyKit ou redémarre mon Mac
**So that** je retrouve mes copies, sans que personne d'autre ne puisse les lire

## Acceptance

- Après avoir quitté puis relancé CopyKit, toutes les copies sont là, dans le même ordre (Swift Testing et XCUITest)
- Le contenu et le texte de recherche sont chiffrés en AES-256-GCM : aucun fichier de l'historique ne contient un texte copié en clair (Swift Testing)
- La clé est rangée dans le Trousseau « protection des données », lisible par CopyKit seul après le premier déverrouillage de la session, sans la marque « cet appareil uniquement » (Swift Testing)
- Si la clé est introuvable alors qu'un historique chiffré existe, CopyKit n'efface rien et affiche « Ton historique est chiffré avec une clé introuvable sur ce Mac », avec Réessayer et Repartir à zéro ; Repartir à zéro passe par une confirmation qui annonce la suppression, épinglés compris (Swift Testing et XCUITest)
- Si la clé est momentanément inaccessible, la capture se met en pause, l'icône de la barre de menus le signale, et aucune copie n'est écrite en clair (Swift Testing)
- Après un arrêt brutal pendant une écriture, l'historique reste lisible, sans copie à moitié écrite (Swift Testing)
