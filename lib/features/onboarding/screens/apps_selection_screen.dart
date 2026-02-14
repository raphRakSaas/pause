import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/preset_app.dart';
import '../../../shared/models/settings.dart';
import '../../../shared/providers/settings_provider.dart';

/// T4 — Écran sélection des apps (liste preset + toggles). Persisté dans Settings.
class AppsSelectionScreen extends ConsumerWidget {
  const AppsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull ?? const Settings();
    final selected = settings.targetApps.toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Apps à contrôler')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Choisis les apps où tu veux une pause avant de scroller.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ...presetApps.map((app) {
            final isOn = selected.contains(app.packageName);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: SwitchListTile(
                title: Text(app.displayName),
                subtitle: Text(
                  app.packageName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                value: isOn,
                onChanged: (value) async {
                  final notifier = ref.read(settingsProvider.notifier);
                  final next = value
                      ? [...selected, app.packageName]
                      : selected.where((p) => p != app.packageName).toList();
                  await notifier.setTargetApps(next);
                },
              ),
            );
          }),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push('/onboarding/objectif'),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
