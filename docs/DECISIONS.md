# /docs/DECISIONS.md

## 2026-02-14
- Choix produit: app “réduire le temps écran” via friction douce + micro-actions
- Plateforme MVP: Android-first
- Tech: Flutter + Kotlin MethodChannel
- State management: Riverpod
- Nav: go_router
- Data: stockage local (Isar recommandé)

## Principes
- MVP = valeur principale (overlay + décision + stats)
- Pas de compte utilisateur
- Pas de sync cloud au MVP
- UX non punitive : toujours un choix