/// Définition d'une micro-action (liste preset, T14).
class MicroActionDef {
  const MicroActionDef({
    required this.id,
    required this.label,
    this.durationSec = 30,
  });

  final String id;
  final String label;
  final int durationSec;
}

/// Liste des micro-actions proposées (respiration, eau, étirements, etc.).
const List<MicroActionDef> microActionDefs = [
  MicroActionDef(id: 'breath', label: 'Respiration', durationSec: 30),
  MicroActionDef(id: 'water', label: 'Boire un verre d\'eau', durationSec: 30),
  MicroActionDef(id: 'stretch', label: 'Étirements', durationSec: 45),
  MicroActionDef(id: 'tidy', label: 'Mini-rangement', durationSec: 60),
  MicroActionDef(id: 'note', label: 'Note rapide', durationSec: 30),
];
