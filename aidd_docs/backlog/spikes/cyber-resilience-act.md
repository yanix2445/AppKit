---
type: spike
status: resolved
source: aidd_docs/tasks/2026_10/2026_10_31_appkit/brainstorm.md
related_to:
  - aidd_docs/product/appkit.md
---

# Spike: Cyber Resilience Act

## Question

AppKit, gratuit, open source et financé par des dons, est-il hors du champ du Cyber Resilience Act (règlement 2024/2847) ?

## Decision

Les obligations légales à remplir avant la première release publique.

## Bounds

- Evidence needed: le texte du règlement (définitions et considérants sur l'activité commerciale et les dons) et le guide de la Commission de juillet 2026.
- Stop when: le texte et le guide ont été lus ; une relecture juridique reste conseillée avant la release.

## Investigation

| Attempt | Evidence | Result |
| ------- | -------- | ------ |
| Guide de la Commission | [Open Source For You, 29 juillet 2026](https://www.opensourceforu.com/2026/07/eu-clarifies-cra-rules-for-non-commercial-open-source/) | Le guide de la Commission (80 pages, non contraignant) indique qu'un logiciel libre disponible gratuitement est en général hors du champ du CRA s'il n'est pas fourni dans le cadre d'une activité commerciale. Les dons volontaires, le parrainage et le financement public ne rendent pas automatiquement un projet commercial, tant que le logiciel reste librement disponible. Deviennent commerciaux : la vente, une édition payante, la monétisation de services par le logiciel, l'exigence de données personnelles au-delà de la sécurité ou de l'interopérabilité, et des dons rendus de fait obligatoires pour accéder au logiciel ou à ses mises à jour essentielles |
| Texte du règlement, d'après des sources secondaires | [OSADL](https://www.osadl.org/?id=4433), [RIPE 89](https://ripe89.ripe.net/presentations/121-COMMERCIAL-DEFINITION-OF-FOSS-IN-CRA-AB-Final.pdf), [Eclipse](https://eclipse.org/lists/open-regulatory-compliance/msg00169.html) | Le règlement ne s'applique qu'aux produits fournis dans le cadre d'une activité commerciale, et un logiciel libre non monétisé par son fabricant n'en relève pas. Une source cite le considérant 15 : accepter des dons **supérieurs aux coûts** de conception, de développement et de mise à disposition du produit compte comme une monétisation. Les numéros de considérants diffèrent selon les sources |

## Outcome

- Result: AppKit est **très probablement hors du champ du CRA**, tant que trois conditions tiennent : le logiciel reste gratuit et librement disponible, les dons restent **volontaires** et ne sont jamais exigés pour utiliser l'app ou recevoir ses mises à jour, et l'app ne demande aucune donnée personnelle au-delà du nécessaire. Point de vigilance : des dons qui dépasseraient durablement les coûts du projet pourraient être vus comme une monétisation. L'application volontaire du CRA décidée dans le brainstorm reste utile : elle prépare AppKit si le cadre changeait.
- Confidence: moyenne (guide de la Commission et sources secondaires concordants, texte officiel non lu directement sur EUR-Lex).
- Remaining uncertainty: le texte exact des considérants sur EUR-Lex ; l'interprétation des dons supérieurs aux coûts.

## Follow-up

- Ajouter au brainstorm : les dons restent volontaires, jamais liés à l'accès à l'app ni aux mises à jour, et leur montant est suivi au regard des coûts du projet.
- Lire les considérants du règlement 2024/2847 sur EUR-Lex et faire relire par un juriste avant la première release publique.
- Mettre à jour la question ouverte correspondante du brainstorm.
