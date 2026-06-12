// lib/features/dashboard/data/repositories/dashboard_repository_impl.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

part 'dashboard_repository_impl.g.dart';

@riverpod
DashboardRepository dashboardRepository(Ref ref) =>
    DashboardRepositoryImpl(ref.watch(dashboardRemoteDatasourceProvider));

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _datasource;
  const DashboardRepositoryImpl(this._datasource);

  @override
  Future<Result<DashboardData>> getDashboard() async {
    try {
      final data = await _datasource.getDashboard();
      return Success(data);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat data dashboard.');
    }
  }
}
