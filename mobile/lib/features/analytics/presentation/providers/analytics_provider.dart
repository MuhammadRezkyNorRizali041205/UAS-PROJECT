// lib/features/analytics/presentation/providers/analytics_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics.dart';

part 'analytics_provider.g.dart';

// ── Period selector state (keepAlive so it survives screen exit) ───────────

@Riverpod(keepAlive: true)
class AnalyticsPeriod extends _$AnalyticsPeriod {
  @override
  String build() => 'week';

  void setPeriod(String period) => state = period;
}

@riverpod
Future<DashboardAnalyticsEntity> analyticsDashboard(Ref ref) async {
  final result = await ref.read(analyticsRepositoryProvider).getDashboard();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

@riverpod
Future<List<HeatmapDayEntity>> analyticsHeatmap(Ref ref) async {
  final result = await ref.read(analyticsRepositoryProvider).getHeatmap();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

@riverpod
Future<SummaryAnalyticsEntity> analyticsSummary(Ref ref) async {
  final period = ref.watch(analyticsPeriodProvider);
  final result =
      await ref.read(analyticsRepositoryProvider).getSummary(period: period);
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}
