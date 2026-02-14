import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/services/permission_service.dart';

/// T7 — Écran permissions : guide Usage Access + Overlay, boutons réglages, vérification état.
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _usageOk = false;
  bool _overlayOk = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addWidgetsBindingObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final usage = await hasUsageAccess();
      final overlay = await canDrawOverlays();
      if (mounted) {
        setState(() {
          _usageOk = usage;
          _overlayOk = overlay;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bothOk = _usageOk && _overlayOk;

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Pour détecter quand tu ouvres une app et afficher une pause, Pause a besoin de deux autorisations.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _PermissionCard(
            title: 'Accès à l\'utilisation',
            subtitle: 'Permet de savoir quelle app est ouverte.',
            isGranted: _usageOk,
            loading: _loading,
            onOpenSettings: () => openUsageAccessSettings(),
            onVerify: _check,
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            title: 'Afficher par-dessus les autres apps',
            subtitle: 'Permet d\'afficher la pause avant d\'entrer dans l\'app.',
            isGranted: _overlayOk,
            loading: _loading,
            onOpenSettings: () => openOverlaySettings(),
            onVerify: _check,
          ),
          const SizedBox(height: 32),
          if (bothOk) ...[
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tout est prêt.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Terminer'),
            ),
          ] else
            OutlinedButton(
              onPressed: _loading ? null : _check,
              child: Text(_loading ? 'Vérification…' : 'Vérifier les permissions'),
            ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.loading,
    required this.onOpenSettings,
    required this.onVerify,
  });

  final String title;
  final String subtitle;
  final bool isGranted;
  final bool loading;
  final VoidCallback onOpenSettings;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGranted ? Icons.check_circle : Icons.pending,
                  color: isGranted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: loading ? null : onOpenSettings,
                  child: const Text('Ouvrir les réglages'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: loading ? null : onVerify,
                  child: const Text('Vérifier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
