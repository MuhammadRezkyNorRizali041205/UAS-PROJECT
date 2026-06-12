// lib/features/analytics/presentation/providers/analytics_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics.dart';

part 'analytics_provider.g.dart';

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
  final result = await ref.read(analyticsRepositoryProvider).getSummary();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}
