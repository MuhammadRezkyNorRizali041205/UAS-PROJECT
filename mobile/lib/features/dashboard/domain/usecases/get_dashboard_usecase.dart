// lib/features/dashboard/domain/usecases/get_dashboard_usecase.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

part 'get_dashboard_usecase.g.dart';

@riverpod
GetDashboardUsecase getDashboardUsecase(Ref ref) =>
    GetDashboardUsecase(ref.watch(dashboardRepositoryProvider));

class GetDashboardUsecase {
  final DashboardRepository _repo;
  const GetDashboardUsecase(this._repo);

  Future<Result<DashboardData>> call() => _repo.getDashboard();
}
