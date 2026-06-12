// lib/features/analytics/presentation/screens/analytics_screen.dart

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton_loader.dart' show SkeletonBox;
import '../../domain/entities/analytics.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync    = ref.watch(analyticsDashboardProvider);
    final heatmapAsync = ref.watch(analyticsHeatmapProvider);
    final summaryAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analitik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(analyticsDashboardProvider);
              ref.invalidate(analyticsHeatmapProvider);
              ref.invalidate(analyticsSummaryProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(analyticsDashboardProvider);
          ref.invalidate(analyticsHeatmapProvider);
          ref.invalidate(analyticsSummaryProvider);
          await Future.wait([
            ref.read(analyticsDashboardProvider.future),
            ref.read(analyticsHeatmapProvider.future),
            ref.read(analyticsSummaryProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            summaryAsync.when(
              loading: () => const _SummarySkeleton(),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (s) => _SummarySection(summary: s),
            ),
            const SizedBox(height: 20),
            dashAsync.when(
              loading: () => const _ChartSkeleton(height: 220),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (d) => _TaskStatsSection(data: d),
            ),
            const SizedBox(height: 20),
            dashAsync.when(
              loading: () => const _ChartSkeleton(height: 200),
              error: (_, __) => const SizedBox.shrink(),
              data: (d) => _PriorityBarChart(byPriority: d.tasksByPriority),
            ),
            const SizedBox(height: 20),
            dashAsync.when(
              loading: () => const _ChartSkeleton(height: 220),
              error: (_, __) => const SizedBox.shrink(),
              data: (d) => _CategoryPieChart(byCategory: d.schedulesByCategory),
            ),
            const SizedBox(height: 20),
            heatmapAsync.when(
              loading: () => const _ChartSkeleton(height: 160),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (days) => _ActivityHeatmap(days: days),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary section
// ─────────────────────────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final SummaryAnalyticsEntity summary;
  const _SummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final pos = summary.weekChange >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Minggu ini',
                value: '${summary.thisWeekCompleted}',
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Minggu lalu',
                value: '${summary.lastWeekCompleted}',
                icon: Icons.history_rounded,
                iconColor: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Perubahan',
                value: '${pos ? '+' : ''}${summary.weekChange}',
                icon: pos
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                iconColor: pos ? AppColors.success : AppColors.danger,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Hari produktif',
                value: summary.mostProductiveDay,
                icon: Icons.star_rounded,
                iconColor: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _StatCard(
          label: 'Jadwal aktif',
          value: '${summary.activeSchedules}',
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.primary,
          wide: true,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool wide;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: wide
                      ? AppTextStyles.headingSmall
                      : AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task stats section
// ─────────────────────────────────────────────────────────────────────────────

class _TaskStatsSection extends StatelessWidget {
  final DashboardAnalyticsEntity data;
  const _TaskStatsSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final t = data.tasks;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Tugas', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: [
                          if (t.completed > 0)
                            PieChartSectionData(
                              value: t.completed.toDouble(),
                              color: AppColors.success,
                              radius: 22,
                              showTitle: false,
                            ),
                          if (t.inProgress > 0)
                            PieChartSectionData(
                              value: t.inProgress.toDouble(),
                              color: AppColors.primary,
                              radius: 22,
                              showTitle: false,
                            ),
                          if (t.pending > 0)
                            PieChartSectionData(
                              value: t.pending.toDouble(),
                              color: AppColors.textMuted,
                              radius: 22,
                              showTitle: false,
                            ),
                          if (t.overdue > 0)
                            PieChartSectionData(
                              value: t.overdue.toDouble(),
                              color: AppColors.danger,
                              radius: 22,
                              showTitle: false,
                            ),
                          if (t.total == 0)
                            PieChartSectionData(
                              value: 1,
                              color: AppColors.border,
                              radius: 22,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${t.completionRate.toStringAsFixed(0)}%',
                          style: AppTextStyles.headingSmall,
                        ),
                        Text(
                          'selesai',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _LegendTile(
                        color: AppColors.success,
                        label: 'Selesai',
                        value: t.completed),
                    const SizedBox(height: 8),
                    _LegendTile(
                        color: AppColors.primary,
                        label: 'Proses',
                        value: t.inProgress),
                    const SizedBox(height: 8),
                    _LegendTile(
                        color: AppColors.textMuted,
                        label: 'Pending',
                        value: t.pending),
                    const SizedBox(height: 8),
                    _LegendTile(
                        color: AppColors.danger,
                        label: 'Terlambat',
                        value: t.overdue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total tugas',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                Text('${t.total}', style: AppTextStyles.labelMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendTile extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _LegendTile(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
        Text(
          '$value',
          style: AppTextStyles.labelMedium
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Priority bar chart
// ─────────────────────────────────────────────────────────────────────────────

class _PriorityBarChart extends StatelessWidget {
  final Map<String, int> byPriority;
  const _PriorityBarChart({required this.byPriority});

  static const _order = ['low', 'medium', 'high', 'critical'];
  static const _labels = {
    'low': 'Rendah',
    'medium': 'Sedang',
    'high': 'Tinggi',
    'critical': 'Kritis',
  };

  @override
  Widget build(BuildContext context) {
    final maxVal =
        byPriority.values.fold(0, (a, b) => a > b ? a : b).toDouble();

    final bars = _order.where(byPriority.containsKey).map((k) {
      return BarChartGroupData(
        x: _order.indexOf(k),
        barRods: [
          BarChartRodData(
            toY: byPriority[k]!.toDouble(),
            color: AppColors.priorityColor(k),
            width: 28,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tugas per Prioritas', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: bars.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: (maxVal + 1).ceilToDouble(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, meta) {
                              if (v == 0 || v == meta.max) {
                                return const SizedBox();
                              }
                              return Text(
                                v.toInt().toString(),
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted, fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final key = _order[v.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _labels[key] ?? key,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.priorityColor(key),
                                      fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: bars,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category pie chart
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryPieChart extends StatefulWidget {
  final Map<String, int> byCategory;
  const _CategoryPieChart({required this.byCategory});

  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  int _touched = -1;

  static const _labels = {
    'lecture': 'Kuliah',
    'practicum': 'Praktikum',
    'seminar': 'Seminar',
    'organization': 'Organisasi',
    'task': 'Tugas',
    'exam': 'Ujian',
  };

  @override
  Widget build(BuildContext context) {
    final entries = widget.byCategory.entries.toList();
    final total = entries.fold(0, (a, e) => a + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jadwal per Kategori', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      pieTouchData: PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, PieTouchResponse? res) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                res == null ||
                                res.touchedSection == null) {
                              _touched = -1;
                              return;
                            }
                            _touched =
                                res.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: List.generate(entries.length, (i) {
                        final e = entries[i];
                        final isTouched = i == _touched;
                        final pct = (e.value / math.max(total, 1) * 100)
                            .toStringAsFixed(0);
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          color: AppColors.categoryColor(e.key),
                          radius: isTouched ? 32 : 24,
                          showTitle: isTouched,
                          title: isTouched ? '$pct%' : '',
                          titleStyle: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white, fontSize: 10),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.categoryColor(e.key),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _labels[e.key] ?? e.key,
                                    style: AppTextStyles.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${e.value}',
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity heatmap
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityHeatmap extends StatelessWidget {
  final List<HeatmapDayEntity> days;
  const _ActivityHeatmap({required this.days});

  static const _dayLabels = ['M', 'S', 'R', 'K', 'J', 'S', 'M'];

  Color _cellColor(int count) {
    if (count == 0) return AppColors.border;
    if (count < 3) return AppColors.primary.withValues(alpha: 0.3);
    if (count < 6) return AppColors.primary.withValues(alpha: 0.55);
    if (count < 10) return AppColors.primary.withValues(alpha: 0.8);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final lookup = <String, int>{
      for (final d in days) _key(d.date): d.count,
    };

    final sorted = List.of(days)..sort((a, b) => a.date.compareTo(b.date));
    final earliest = sorted.first.date;
    final latest = sorted.last.date;

    final startSunday =
        earliest.subtract(Duration(days: earliest.weekday % 7));
    final endSaturday =
        latest.add(Duration(days: 6 - latest.weekday % 7));

    final weeks =
        (endSaturday.difference(startSunday).inDays + 1) ~/ 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aktivitas Harian', style: AppTextStyles.headingSmall),
          const SizedBox(height: 4),
          Text(
            'Aktivitas tugas & kehadiran 16 minggu terakhir',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(width: 14),
              ...List.generate(
                7,
                (i) => Expanded(
                  child: Center(
                    child: Text(
                      _dayLabels[i],
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted, fontSize: 9),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(builder: (context, constraints) {
            final cellSize = (constraints.maxWidth - 14) / 7;
            return Column(
              children: List.generate(weeks, (week) {
                final weekStart =
                    startSunday.add(Duration(days: week * 7));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        child: weekStart.day <= 7
                            ? Text(
                                _monthAbbr(weekStart.month),
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted, fontSize: 8),
                              )
                            : null,
                      ),
                      ...List.generate(7, (d) {
                        final date =
                            weekStart.add(Duration(days: d));
                        final count = lookup[_key(date)] ?? 0;
                        final isToday = _isToday(date);
                        return Container(
                          width: cellSize - 3,
                          height: cellSize - 3,
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: _cellColor(count),
                            borderRadius: BorderRadius.circular(3),
                            border: isToday
                                ? Border.all(
                                    color: AppColors.primary, width: 1.5)
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Kurang',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 10),
              ),
              const SizedBox(width: 4),
              ...[0, 2, 5, 8, 10].map(
                (c) => Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: _cellColor(c),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Banyak',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _monthAbbr(int month) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeletons & error card
// ─────────────────────────────────────────────────────────────────────────────

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBox(height: 60, borderRadius: 12),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 60, borderRadius: 12)),
            SizedBox(width: 10),
            Expanded(child: SkeletonBox(height: 60, borderRadius: 12)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 60, borderRadius: 12)),
            SizedBox(width: 10),
            Expanded(child: SkeletonBox(height: 60, borderRadius: 12)),
          ],
        ),
      ],
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  final double height;
  const _ChartSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(height: height, borderRadius: 16);
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.replaceAll('Exception: ', ''),
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
