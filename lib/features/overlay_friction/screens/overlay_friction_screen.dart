import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/preset_app.dart';

/// T10 — Écran overlay friction : affiché quand une app ciblée est ouverte.
/// UI minimal "Pause" (Flow 1). Raison + choix 5 min / micro-action viendront en Sprint 3.
class OverlayFrictionScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = displayNameFor(packageName);

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
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Ouvrir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
