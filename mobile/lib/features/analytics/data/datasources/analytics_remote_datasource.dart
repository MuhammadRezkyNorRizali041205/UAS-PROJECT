// lib/features/analytics/data/datasources/analytics_remote_datasource.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/analytics.dart';

part 'analytics_remote_datasource.g.dart';

@riverpod
AnalyticsRemoteDatasource analyticsRemoteDatasource(Ref ref) =>
    AnalyticsRemoteDatasource(ref.watch(dioClientProvider));

class AnalyticsRemoteDatasource {
  final DioClient _client;
  const AnalyticsRemoteDatasource(this._client);

  Future<DashboardAnalyticsEntity> getDashboard() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsDashboard,
    );
    final d = res['data'] as Map<String, dynamic>;

    final t = d['tasks'] as Map<String, dynamic>;
    final tasks = TaskStatsEntity(
      total:          (t['total'] as num).toInt(),
      completed:      (t['completed'] as num).toInt(),
      pending:        (t['pending'] as num).toInt(),
      inProgress:     (t['in_progress'] as num).toInt(),
      overdue:        (t['overdue'] as num).toInt(),
      completionRate: (t['completion_rate'] as num).toDouble(),
    );

    final byPriority = (d['tasks_by_priority'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as num).toInt()));

    final byCat = (d['schedules_by_category'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as num).toInt()));

    return DashboardAnalyticsEntity(
      tasks:                tasks,
      tasksByPriority:      byPriority,
      schedulesByCategory:  byCat,
      attendanceThisMonth:  (d['attendance_this_month'] as num).toInt(),
    );
  }

  Future<List<HeatmapDayEntity>> getHeatmap({int weeks = 16}) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsHeatmap,
      queryParameters: {'weeks': weeks},
    );
    final list = res['data'] as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return HeatmapDayEntity(
        date:  DateTime.parse(m['date'] as String),
        count: (m['count'] as num).toInt(),
      );
    }).toList();
  }

  Future<SummaryAnalyticsEntity> getSummary({String period = 'week'}) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsSummary,
      queryParameters: {'period': period},
    );
    final d = res['data'] as Map<String, dynamic>;

    final rawChart = d['chart_data'] as List<dynamic>? ?? [];
    final chartData = rawChart.map((e) {
      final m = e as Map<String, dynamic>;
      return ChartDataPoint(
        label: m['label'] as String? ?? '',
        value: (m['value'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    return SummaryAnalyticsEntity(
      thisWeekCompleted: (d['this_week_completed'] as num?)?.toInt() ?? 0,
      lastWeekCompleted: (d['last_week_completed'] as num?)?.toInt() ?? 0,
      weekChange:        (d['week_change'] as num?)?.toInt() ?? 0,
      mostProductiveDay: d['most_productive_day'] as String? ?? '-',
      activeSchedules:   (d['active_schedules'] as num?)?.toInt() ?? 0,
      period:            d['period'] as String? ?? period,
      chartData:         chartData,
    );
  }
}
