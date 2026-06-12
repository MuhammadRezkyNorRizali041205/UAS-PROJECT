// lib/features/dashboard/domain/repositories/dashboard_repository.dart

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';

abstract interface class DashboardRepository {
  Future<Result<DashboardData>> getDashboard();
}
