# /docs/ARCHITECTURE.md

## Stack
- Flutter (stable channel)
- Android-first (MVP)
- Code natif Android (Kotlin) via MethodChannel
- Stockage local : Isar (recommandé) ou Hive (plus simple) / SQLite (si besoin)
- State management : Riverpod (simple et scalable)
- Navigation : go_router
- Charts : fl_chart (simple)

## Modules (lib/)
- lib/app/ (bootstrap, theme, router)
- lib/features/onboarding/
- lib/features/overlay_friction/
- lib/features/micro_actions/
- lib/features/stats/
- lib/features/settings/
- lib/shared/ (widgets, utils, models)

## Android (android/)
- Foreground Service : monitoring du foreground app
- Permissions :
  - Usage Access (PACKAGE_USAGE_STATS)
  - Draw over other apps (SYSTEM_ALERT_WINDOW)
- Overlay :
  - Activity/Window overlay (selon implémentation)
  - Communication avec Flutter via MethodChannel

## Conventions
- One feature = one folder
- Modèles immutables
- AC testables (unit/widget)
- Logs structurés en debug
- Commits : feat:, fix:, chore:, docs:

## Data model (local)
Event:
- id
- timestamp
- packageName
- decision: {session_short, micro_action, bypass}
- reason: enum (bored, stress, procrastinate, quick5, other)
- sessionDurationSec (nullable)
MicroActionLog:
- id
- timestamp
- actionId
- durationSec
Settings:
- targetApps[]
- dailyLimitMinutes
- noScrollAfterTime (nullable)
- frictionLevel (soft/medium/hard)
- sessionDefaultMinutes (default 5)