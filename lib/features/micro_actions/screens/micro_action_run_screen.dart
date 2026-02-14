import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/micro_action.dart';
import '../../../shared/storage/storage_service.dart';

/// T14 — Affiche une micro-action, bouton Démarrer (timer optionnel), Terminé -> log + fermer overlay.
class MicroActionRunScreen extends StatefulWidget {
  const MicroActionRunScreen({super.key});

  @override
  State<MicroActionRunScreen> createState() => _MicroActionRunScreenState();
}

class _MicroActionRunScreenState extends State<MicroActionRunScreen> {
  late final MicroActionDef _action;
  bool _started = false;
  int _elapsedSec = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _action = microActionDefs[rnd.nextInt(microActionDefs.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onStart() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSec++);
    });
  }

  Future<void> _onDone() async {
    _timer?.cancel();
    await addMicroActionLog(
      actionId: _action.id,
      durationSec: _elapsedSec > 0 ? _elapsedSec : _action.durationSec,
    );
    if (!mounted) return;
    context.pop();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.self_improvement_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _action.label,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_started)
                FilledButton(
                  onPressed: _onStart,
                  child: const Text('Démarrer'),
                )
              else ...[
                Text(
                  'Prends ton temps.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _onDone,
                  child: const Text('Terminé'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
