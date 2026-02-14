import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/settings_provider.dart';

/// T5 — Objectif minutes/jour + option "pas de scroll après HH:MM".
/// [fromSettings] : si true, bouton "Enregistrer" et pop (T17).
class ObjectiveScreen extends ConsumerStatefulWidget {
  const ObjectiveScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  @override
  ConsumerState<ObjectiveScreen> createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends ConsumerState<ObjectiveScreen> {
  static const int _minMinutes = 30;
  static const int _maxMinutes = 360;
  static const int _defaultMinutes = 120;

  int _minutes = _defaultMinutes;
  bool _noScrollAfterEnabled = false;
  int? _noScrollAfterMinutes; // minutes depuis minuit (0..1439)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = ref.read(settingsProvider).valueOrNull;
      if (s != null) {
        setState(() {
          _minutes = s.dailyLimitMinutes.clamp(_minMinutes, _maxMinutes);
          _noScrollAfterMinutes = s.noScrollAfterMinutes;
          _noScrollAfterEnabled = s.noScrollAfterMinutes != null;
        });
      }
    });
  }

  int get _minutesSinceMidnight => _noScrollAfterMinutes ?? 22 * 60 + 30; // 22h30 par défaut

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Objectif quotidien')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Combien de minutes par jour sur ces apps ?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_minutes min',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _minutes.toDouble(),
            min: _minMinutes.toDouble(),
            max: _maxMinutes.toDouble(),
            divisions: (_maxMinutes - _minMinutes) ~/ 15,
            label: '$_minutes min',
            onChanged: (v) {
              setState(() => _minutes = v.round());
              _persist();
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Ne plus scroller après une certaine heure (optionnel)',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Activer le couvre-feu'),
            value: _noScrollAfterEnabled,
            onChanged: (value) {
              setState(() {
                _noScrollAfterEnabled = value;
                if (value && _noScrollAfterMinutes == null) {
                  _noScrollAfterMinutes = 22 * 60 + 30;
                } else if (!value) {
                  _noScrollAfterMinutes = null;
                }
                _persist();
              });
            },
          ),
          if (_noScrollAfterEnabled) ...[
            ListTile(
              title: Text('Après ${_formatMinutesSinceMidnight(_minutesSinceMidnight)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(context),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              _persist();
              if (widget.fromSettings) {
                context.pop();
              } else {
                context.push('/onboarding/friction');
              }
            },
            child: Text(widget.fromSettings ? 'Enregistrer' : 'Continuer'),
          ),
        ],
      ),
    );
  }

  String _formatMinutesSinceMidnight(int m) {
    final h = m ~/ 60;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(BuildContext context) async {
    final h = _minutesSinceMidnight ~/ 60;
    final min = _minutesSinceMidnight % 60;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: min),
    );
    if (time != null) {
      setState(() {
        _noScrollAfterMinutes = time.hour * 60 + time.minute;
        _persist();
      });
    }
  }

  Future<void> _persist() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.update((s) => s.copyWith(
          dailyLimitMinutes: _minutes,
          noScrollAfterMinutes: _noScrollAfterEnabled ? _noScrollAfterMinutes : null,
        ));
  }
}
