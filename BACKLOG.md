

## Priorités
P0 = indispensable MVP
P1 = améliore l’adhérence
P2 = nice-to-have

---

## EPIC A — Onboarding & permissions (P0)

### US-A1 (P0) Welcome
En tant qu’utilisateur, je veux comprendre la promesse en 10 secondes, afin de savoir pourquoi installer l’app.
AC:
- 1 écran, valeur claire, CTA “Commencer”

### US-A2 (P0) Sélection apps
En tant qu’utilisateur, je veux sélectionner les apps de scroll à contrôler.
AC:
- Liste d’apps (au minimum preset + saisie/manuelle)
- Persisté localement

### US-A3 (P0) Objectif minutes/jour
En tant qu’utilisateur, je veux fixer une limite quotidienne.
AC:
- Slider minutes/jour
- Affichage sur Home

### US-A4 (P0) Niveau de friction
En tant qu’utilisateur, je veux choisir Soft/Medium/Hard.
AC:
- Soft: timer 2–3s + “Ouvrir”
- Medium: question + choix “5 min / micro-action”
- Hard: micro-action obligatoire

### US-A5 (P0) Permissions Android
En tant qu’utilisateur, je veux être guidé pour activer Usage Access + Overlay.
AC:
- Écran de guide + boutons qui ouvrent Settings
- Détection “permission OK” avant de continuer

---

## EPIC B — Détection app + overlay (P0)

### US-B1 (P0) Détecter l’app au premier plan
En tant que système, je détecte quand une app ciblée est ouverte.
AC:
- Service Android actif
- Check périodique (ex: 500ms–1s) configurable
- Ignore apps non ciblées

### US-B2 (P0) Afficher overlay friction
En tant qu’utilisateur, je vois l’overlay avant d’entrer dans l’app ciblée.
AC:
- Overlay < 1 sec
- UI minimal
- Bouton quitter overlay (selon niveau)

### US-B3 (P0) Enregistrer un “event”
En tant que système, j’enregistre chaque ouverture (app, timestamp).
AC:
- Stockage local (SQLite/Isar/Hive)
- Utilisé par Stats

---

## EPIC C — Friction UX (P0)

### US-C1 (P0) Choisir une raison
En tant qu’utilisateur, je choisis une raison (ennui/stress/procrastine…).
AC:
- 5 raisons + “autre”
- Persisté dans l’event

### US-C2 (P0) Session courte 5 min
En tant qu’utilisateur, je peux choisir “OK 5 minutes”.
AC:
- Timer 5 min
- Fin de session: prompt stop / +2 min (max 2)

### US-C3 (P0) Micro-action
En tant qu’utilisateur, je peux faire une micro-action rapide puis ouvrir l’app.
AC:
- 10 actions minimum
- Bouton “Terminé” log + autorisation

---

## EPIC D — Home & Stats (P0)

### US-D1 (P0) Home dashboard
En tant qu’utilisateur, je vois minutes/jour, ouvertures, progression.
AC:
- minutes sur apps ciblées (estimées via events)
- objectif + barre progression
- streak simple (jours où < objectif)

### US-D2 (P0) Stats 7 jours
En tant qu’utilisateur, je vois une tendance sur 7 jours.
AC:
- minutes/jour (line/bar)
- top raisons
- heures critiques (simple)

---

## EPIC E — Paramètres (P1)

### US-E1 (P1) Modifier apps/objectif
AC:
- UI settings + persistance

### US-E2 (P1) Personnaliser micro-actions
AC:
- activer/désactiver actions

---

## EPIC F — Premium / Viral (P2)
- Export hebdo
- Challenges
- Partage carte “temps économisé”