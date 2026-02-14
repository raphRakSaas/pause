import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/friction_level.dart';
import '../../../shared/models/micro_action.dart';
import '../../../shared/models/settings.dart';
import '../../../shared/providers/settings_provider.dart';

/// T17 — Paramètres : apps, objectif, friction, micro-actions.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Map<FrictionLevel, String> _frictionLabels = {
    FrictionLevel.soft: 'Doux',
    FrictionLevel.medium: 'Moyen',
    FrictionLevel.hard: 'Strict',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).valueOrNull ?? const Settings();

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          ListTile(
            title: const Text('Apps ciblées'),
            subtitle: Text(
              '${settings.targetApps.length} app(s) sélectionnée(s)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/onboarding/apps?fromSettings=1'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Objectif quotidien'),
            subtitle: Text(
              '${settings.dailyLimitMinutes} min/jour'
              '${settings.noScrollAfterMinutes != null ? ' · Couvre-feu actif' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/onboarding/objectif?fromSettings=1'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Niveau de friction'),
            subtitle: Text(
              _frictionLabels[settings.frictionLevel] ?? settings.frictionLevel.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/onboarding/friction?fromSettings=1'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'Micro-actions',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            'Choisis les micro-actions proposées lors d\'une pause.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...microActionDefs.map((def) {
            final enabled =
                !settings.disabledMicroActionIds.contains(def.id);
            return SwitchListTile(
              title: Text(def.label),
              subtitle: Text(
                '${def.durationSec} s',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: enabled,
              onChanged: (value) async {
                await ref
                    .read(settingsProvider.notifier)
                    .setMicroActionEnabled(def.id, value);
              },
            );
          }),
        ],
      ),
    );
  }
}
