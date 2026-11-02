# Backlog

## Supports

| Support | Authority for | Role |
| --- | --- | --- |
| `aidd_docs/backlog/` | le contenu des artefacts : epics, stories, spikes, defects, tasks, avec leurs critères d'acceptation | la source détaillée, écrite par les skills `aidd-pm` |
| GitHub Issues | le statut et la discussion de chaque artefact | le suivi visible, relié aux PR par « Closes #n » |

## Structure

```mermaid
flowchart TB
  goal["Product goal"] --> epic["Epic"]
  epic --> story["User Story"]
  story --> task["Task"]
  spike["Spike"] -. "resolves uncertainty for" .-> story
  defect["Defect"] -. "affects" .-> story
```

## Relations

- Cross-support: le fichier local cite son issue (`#n`) et l'issue renvoie vers le fichier
