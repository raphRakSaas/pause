import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/event_reason.dart';
import '../../../shared/providers/stats_provider.dart';

/// T16 — Stats 7 jours : tendance minutes/jour, top raisons, heures de pic.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const Map<EventReason, String> _reasonLabels = {
    EventReason.bored: 'Ennui',
    EventReason.stress: 'Stress',
    EventReason.procrastinate: 'Procrastination',
    EventReason.quick5: 'Juste 5 min',
    EventReason.other: 'Autre',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(stats7Provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: statsAsync.when(
        data: (s) => _Body(stats: s, theme: theme, reasonLabels: _reasonLabels),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erreur: $e',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.stats,
    required this.theme,
    required this.reasonLabels,
  });

  final Stats7 stats;
  final ThemeData theme;
  final Map<EventReason, String> reasonLabels;

  String _dayLabel(DateTime day) {
    const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return weekdays[day.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final maxMinutes = stats.minutesPerDay.isEmpty
        ? 1
        : stats.minutesPerDay.map((e) => e.minutes).reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Text(
          'Tendance 7 jours (minutes)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxMinutes * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= 0 && i < stats.minutesPerDay.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _dayLabel(stats.minutesPerDay[i].day),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 24,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: stats.minutesPerDay.asMap().entries.map((e) {
                final minutes = e.value.minutes.toDouble();
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: minutes,
                      color: theme.colorScheme.primary,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                  showingTooltipIndicators: [],
                );
              }).toList(),
            ),
            duration: const Duration(milliseconds: 200),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Top raisons (7j)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...() {
          final entries = stats.topReasons.entries
              .where((e) => e.value > 0)
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return entries.map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(reasonLabels[e.key] ?? e.key.name),
                    trailing: Text(
                      '${e.value}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ));
        }(),
        if (stats.topReasons.values.every((v) => v == 0))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Aucune donnée sur 7 jours.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Heures de craquage (7j)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _PeakHoursChart(theme: theme, peakHours: stats.peakHours),
      ],
    );
  }
}

class _PeakHoursChart extends StatelessWidget {
  const _PeakHoursChart({
    required this.theme,
    required this.peakHours,
  });

  final ThemeData theme;
  final Map<int, int> peakHours;

  @override
  Widget build(BuildContext context) {
    final maxCount = peakHours.values.isEmpty
        ? 1
        : peakHours.values.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final h = value.toInt();
                  if (h >= 0 && h < 24) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '$h h',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 20,
                interval: 2,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 20,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(24, (i) {
            final count = (peakHours[i] ?? 0).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count,
                  color: theme.colorScheme.secondary,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ],
              showingTooltipIndicators: [],
            );
          }),
        ),
        duration: const Duration(milliseconds: 200),
      ),
    );
  }
}
