import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/event_decision.dart';
import '../../../shared/models/event_reason.dart';
import '../../../shared/models/preset_app.dart';
import '../../../shared/storage/storage_service.dart';

/// T10 + T12 — Overlay friction : "Pourquoi tu ouvres ?" + choix 5 min / micro-action / Ouvrir.
class OverlayFrictionScreen extends StatefulWidget {
  const OverlayFrictionScreen({
    super.key,
    required this.packageName,
  });

  final String packageName;

  /// Nom affiché pour le package (préset ou package brut).
  static String displayNameFor(String pkg) {
    for (final a in presetApps) {
      if (a.packageName == pkg) return a.displayName;
    }
    return pkg;
  }

  @override
  State<OverlayFrictionScreen> createState() => _OverlayFrictionScreenState();
}

class _OverlayFrictionScreenState extends State<OverlayFrictionScreen> {
  EventReason? _selectedReason;

  static const Map<EventReason, String> _reasonLabels = {
    EventReason.bored: 'Ennui',
    EventReason.stress: 'Stress',
    EventReason.procrastinate: 'Procrastination',
    EventReason.quick5: 'Juste 5 min',
    EventReason.other: 'Autre',
  };

  Future<void> _onChoice(EventDecision decision) async {
    final reason = _selectedReason ?? EventReason.other;
    if (decision == EventDecision.sessionShort) {
      final eventId = await addEvent(
        packageName: widget.packageName,
        reason: reason,
        decision: EventDecision.sessionShort,
      );
      if (!mounted) return;
      context.push(
        '/session-timer?eventId=${Uri.encodeComponent(eventId)}',
      );
      return;
    }
    if (decision == EventDecision.microAction) {
      await addEvent(
        packageName: widget.packageName,
        reason: reason,
        decision: EventDecision.microAction,
      );
      if (!mounted) return;
      context.push('/micro-action');
      return;
    }
    await addEvent(
      packageName: widget.packageName,
      reason: reason,
      decision: EventDecision.bypass,
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = OverlayFrictionScreen.displayNameFor(widget.packageName);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pause_circle_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Pause',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu viens d\'ouvrir $displayName.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Pourquoi tu ouvres ?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: EventReason.values.map((r) {
                  final selected = _selectedReason == r;
                  return FilterChip(
                    label: Text(_reasonLabels[r]!),
                    selected: selected,
                    onSelected: (v) =>
                        setState(() => _selectedReason = v ? r : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => _onChoice(EventDecision.sessionShort),
                child: const Text('OK 5 minutes'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _onChoice(EventDecision.microAction),
                child: const Text('Micro-action 30 s'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _onChoice(EventDecision.bypass),
                child: const Text('Ouvrir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
