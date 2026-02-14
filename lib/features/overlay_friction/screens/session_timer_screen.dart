import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/settings_provider.dart';
import '../../../shared/storage/storage_service.dart';

/// T13 — Timer de session (5 min par défaut). Fin : Stop ou +2 min (max 2 fois). Log durée effective.
class SessionTimerScreen extends ConsumerStatefulWidget {
  const SessionTimerScreen({
    super.key,
    required this.eventId,
  });

  final String eventId;

  @override
  ConsumerState<SessionTimerScreen> createState() => _SessionTimerScreenState();
}

class _SessionTimerScreenState extends ConsumerState<SessionTimerScreen> {
  static const int _extraMinutesCap = 2;
  static const int _extraMinutesPerTap = 2;

  Timer? _timer;
  int _remainingSec = 0;
  int _totalElapsedSec = 0;
  int _extraTapsUsed = 0;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _startFromSettings();
  }

  void _startFromSettings() {
    final settings = ref.read(settingsProvider).valueOrNull;
    final minutes = settings?.sessionDefaultMinutes ?? 5;
    setState(() {
      _remainingSec = minutes * 60;
      _totalElapsedSec = 0;
      _extraTapsUsed = 0;
      _ended = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer t) {
    if (!mounted) return;
    setState(() {
      if (_remainingSec > 0) {
        _remainingSec--;
        _totalElapsedSec++;
      } else {
        t.cancel();
        _ended = true;
      }
    });
  }

  Future<void> _onStop() async {
    _timer?.cancel();
    await updateEventSessionDuration(widget.eventId, _totalElapsedSec);
    if (!mounted) return;
    context.pop();
    context.pop();
  }

  Future<void> _onAdd2Min() async {
    if (_extraTapsUsed >= _extraMinutesCap) return;
    setState(() {
      _extraTapsUsed++;
      _remainingSec += _extraMinutesPerTap * 60;
      _ended = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final min = _remainingSec ~/ 60;
    final sec = _remainingSec % 60;
    final canAdd2 = _extraTapsUsed < _extraMinutesCap;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Session',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              if (_ended) ...[
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _onStop,
                  child: const Text('Stop'),
                ),
                if (canAdd2) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _onAdd2Min,
                    child: const Text('+2 min'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
