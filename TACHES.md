Liste des tâches (tickets) prêt pour tes agents Cursor

Sprint 0 — Repo & base
	1.	T0 Init Flutter project + structure folders (lib/features, docs)
	2.	T1 Setup Riverpod + go_router + theme (Apple-like)
	3.	T2 Setup local storage (Isar/Hive) + models Event/Settings

Sprint 1 — Onboarding
	4.	T3 Écran Welcome
	5.	T4 Écran sélection apps (MVP: liste preset + toggles)
	6.	T5 Écran objectif minutes/jour + no-scroll after
	7.	T6 Écran friction level
	8.	T7 Écran permissions + vérification état

Sprint 2 — Android service + overlay
	9.	T8 Kotlin: foreground service + polling app foreground
	10.	T9 MethodChannel: events -> Flutter (appOpened(package))
	11.	T10 Overlay friction (Flutter screen “pause”) déclenché
	12.	T11 Log event (app + timestamp)

Sprint 3 — Decisions & micro-actions
	13.	T12 Raison + choix “5 min/micro-action”
	14.	T13 Session timer 5 min + end prompt (+2min cap)
	15.	T14 Micro-actions list + écran + log

Sprint 4 — Dashboard & stats
	16.	T15 Home dashboard (minutes, opens, progress, streak)
	17.	T16 Stats 7 jours (trend + top reasons + peak hours)
	18.	T17 Settings (apps, limit, friction level, micro-actions)

Sprint 5 — QA & hardening
	19.	T18 Testplan execution + fixes
	20.	T19 Unit tests stats/streak + widget tests Home
	21.	T20 Polishing UI + empty states + error states permissions