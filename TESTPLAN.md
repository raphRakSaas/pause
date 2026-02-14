# /docs/TESTPLAN.md

## Stratégie
- MVP: tests widget (UI), unit tests (logic), tests manuels systématiques
- Focus: permissions, overlay, stabilité du service

## Checklists manuelles (MVP)

### Onboarding
- [ ] Welcome -> continue
- [ ] Sélection apps sauvegardée
- [ ] Objectif minutes/jour sauvegardé
- [ ] Friction level sauvegardé
- [ ] Permissions : boutons ouvrent Settings
- [ ] Détection “permission OK” correctement

### Overlay/Friction
- [ ] Ouvrir TikTok -> overlay apparaît
- [ ] Sélectionner une raison -> persistée
- [ ] “OK 5 minutes” -> timer démarre
- [ ] Fin timer -> prompt stop/+2min
- [ ] “Micro-action” -> action affiche, “Terminé” log, puis ouverture

### Service
- [ ] Après reboot, service relancé (si prévu)
- [ ] Conso batterie acceptable (check à la main)
- [ ] Pas de crash si permission retirée

### Stats
- [ ] Home minutes/jour cohérents
- [ ] 7 jours: trend affiche
- [ ] top raisons correct

## Tests automatisés (minimum)
- Unit: calcul minutes/jour, streak, agrégations stats
- Widget: Home, Friction overlay UI, Micro-action screen

## Cas limites
- Permission retirée pendant usage
- App ciblée ouverte en boucle
- Overlay affiché au dessus de lockscreen (à contrôler)
- Crash du service