// lib/features/dashboard/presentation/providers/dashboard_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardData> dashboardData(Ref ref) async {
  final result = await ref.read(getDashboardUsecaseProvider).call();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}
