// lib/features/analytics/data/repositories/analytics_repository_impl.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analytics.dart';
import '../datasources/analytics_remote_datasource.dart';

part 'analytics_repository_impl.g.dart';

@riverpod
AnalyticsRepositoryImpl analyticsRepository(Ref ref) =>
    AnalyticsRepositoryImpl(ref.watch(analyticsRemoteDatasourceProvider));

class AnalyticsRepositoryImpl {
  final AnalyticsRemoteDatasource _ds;
  const AnalyticsRepositoryImpl(this._ds);

  Future<Result<DashboardAnalyticsEntity>> getDashboard() async {
    try {
      return Success(await _ds.getDashboard());
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat analitik.');
    }
  }

  Future<Result<List<HeatmapDayEntity>>> getHeatmap({int weeks = 16}) async {
    try {
      return Success(await _ds.getHeatmap(weeks: weeks));
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat heatmap.');
    }
  }

  Future<Result<SummaryAnalyticsEntity>> getSummary() async {
    try {
      return Success(await _ds.getSummary());
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat ringkasan.');
    }
  }
}
