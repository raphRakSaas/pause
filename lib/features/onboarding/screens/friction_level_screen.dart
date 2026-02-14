import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/friction_level.dart';
import '../../../shared/models/settings.dart';
import '../../../shared/providers/settings_provider.dart';

/// T6 — Niveau de friction : Soft / Medium / Hard (US-A4).
/// [fromSettings] : si true, bouton "Enregistrer" et pop (T17).
class FrictionLevelScreen extends ConsumerWidget {
  const FrictionLevelScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull ?? const Settings();
    final selected = settings.frictionLevel;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Niveau de friction')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Comment veux-tu que Pause t\'accompagne ?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _LevelCard(
            level: FrictionLevel.soft,
            title: 'Doux',
            subtitle: 'Pause 2–3 secondes puis bouton « Ouvrir »',
            isSelected: selected == FrictionLevel.soft,
            onTap: () => _select(ref, FrictionLevel.soft),
          ),
          const SizedBox(height: 12),
          _LevelCard(
            level: FrictionLevel.medium,
            title: 'Moyen',
            subtitle: 'Question « Pourquoi tu ouvres ? » + choix 5 min ou micro-action',
            isSelected: selected == FrictionLevel.medium,
            onTap: () => _select(ref, FrictionLevel.medium),
          ),
          const SizedBox(height: 12),
          _LevelCard(
            level: FrictionLevel.hard,
            title: 'Strict',
            subtitle: 'Micro-action obligatoire avant d\'ouvrir l\'app',
            isSelected: selected == FrictionLevel.hard,
            onTap: () => _select(ref, FrictionLevel.hard),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              if (fromSettings) {
                context.pop();
              } else {
                context.push('/onboarding/permissions');
              }
            },
            child: Text(fromSettings ? 'Enregistrer' : 'Continuer'),
          ),
        ],
      ),
    );
  }

  Future<void> _select(WidgetRef ref, FrictionLevel level) async {
    await ref.read(settingsProvider.notifier).setFrictionLevel(level);
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final FrictionLevel level;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 1 : 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.5)
          : theme.cardTheme.color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
