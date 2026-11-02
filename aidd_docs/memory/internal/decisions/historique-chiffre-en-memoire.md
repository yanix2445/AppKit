# Historique chiffré, lu en mémoire

- Date: 2026-11-03
- Status: Accepted
- Supersedes: aidd_docs/memory/internal/decisions/architecture-mv-feature-core.md (sa partie stockage seulement)

## Context

L'ADR d'architecture prévoyait des modèles SwiftData lus directement par les
vues avec `@Query`. Depuis, trois décisions ont changé la donne :

- l'historique est chiffré en AES-256-GCM, avec une clé dans le Trousseau, et
  aucune copie ne doit jamais être écrite en clair, même temporairement ;
- le [spike sur la recherche](../../../backlog/spikes/chiffrement-et-recherche.md)
  a montré que la seule approche assez rapide garde un index déchiffré en
  mémoire : 3,8 ms pour 10 000 éléments et 40 ms pour 100 000, contre 397 ms
  en déchiffrant à chaque recherche ;
- hors App Sandbox ([ADR](hors-app-sandbox.md)), les fichiers de l'historique
  ne sont protégés que par ce chiffrement.

`@Query` ne peut ni lire ni chercher dans un contenu chiffré.

## Decision

SwiftData ne stocke que des enregistrements chiffrés : le contenu, les formats
et le texte de recherche sont des blocs chiffrés, et seules les données
nécessaires au tri et au nettoyage restent lisibles (date, taille, catégorie,
épinglé, volumineux). Les vues lisent un historique déchiffré en mémoire, un
objet `@Observable`, avec un index de recherche contigu chargé à l'ouverture du
bandeau et libéré à sa fermeture.

## Alternatives

| Alternative | Raison |
| --- | --- |
| `@Query` sur des modèles SwiftData en clair | Contraire aux lignes rouges : l'historique serait lisible sur le disque |
| Déchiffrer à chaque recherche | 397 ms pour 10 000 éléments, loin des 50 ms exigés |
| Un stockage maison, un fichier chiffré par copie | Plus de code à écrire et à fiabiliser (écritures atomiques, migrations), pour un gain nul face à SwiftData |
| Chiffrer tout, y compris la date et la taille | Le nettoyage par l'âge et par la place devrait tout déchiffrer, ce qui casse les budgets de sobriété |

## Consequences

- ✅ Rien de copié n'est lisible sur le disque ; la recherche tient ses budgets.
- ✅ SwiftData garde ce qu'il fait bien : écritures atomiques, migrations de
  schéma, stockage externe des gros blocs.
- ⚠️ La date, la taille, la catégorie et l'état « épinglé » restent lisibles.
  Ils ne révèlent rien du contenu, mais ce choix est assumé ici.
- ⚠️ Le chiffrement, le déchiffrement et l'index vivent dans `CopyKitData`,
  hors du fil principal ; le Trousseau dans `CopyKitSystem`.
- ⚠️ Les vues n'utilisent pas `@Query` pour l'historique : `database.md` le dit.
- La mémoire remonte quand le bandeau est ouvert (environ 40 Mo pour 100 000
  éléments), puis redescend à sa fermeture, ce qui tient la limite de 80 Mo au
  repos.
