# Pause — Guide pour les agents Cursor (multi-agent)

Ce fichier donne le contexte commun à tous les agents qui travaillent sur le projet Pause.

## À lire en priorité
| Fichier | Rôle |
|---------|------|
| `docs/PRODUCT.md` | Vision, promesse, personas, objectifs MVP |
| `docs/FLOWS.md` | Navigation et flows (onboarding, friction, session, micro-actions, dashboard, stats, paramètres) |
| `ARCHITECTURE.md` | Stack, modules `lib/`, Android, modèles de données, conventions |
| `DECISIONS.md` | Choix produit et tech, principes |
| `TACHES.md` | Tickets par sprint (T0–T20) |

## Découpage pour plusieurs agents en parallèle
Chaque agent peut prendre un **sprint** ou un **bloc de tâches** pour limiter les conflits :

- **Sprint 0** (T0–T2) : init Flutter, structure, Riverpod, go_router, thème, stockage + modèles
- **Sprint 1** (T3–T7) : onboarding (Welcome, apps, objectif, friction, permissions)
- **Sprint 2** (T8–T11) : service Android, MethodChannel, overlay friction, log events
- **Sprint 3** (T12–T14) : raison + choix 5 min / micro-action, timer session, micro-actions
- **Sprint 4** (T15–T17) : dashboard, stats 7j, settings
- **Sprint 5** (T18–T20) : testplan, tests unitaires/widget, polish UI

Respecter l’ordre des sprints si un agent dépend du travail d’un autre (ex. Sprint 1 après Sprint 0).

## Rappels
- Répondre en français quand c’est la langue du projet.
- Ne pas créer de fichiers de test sans que l’utilisateur le demande.
- Éviter les régressions : en cas de risque, proposer une approche alternative.
