// lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

part 'dashboard_remote_datasource.g.dart';

@riverpod
DashboardRemoteDatasource dashboardRemoteDatasource(Ref ref) =>
    DashboardRemoteDatasource(ref.watch(dioClientProvider));

class DashboardRemoteDatasource {
  final DioClient _client;
  const DashboardRemoteDatasource(this._client);

  Future<DashboardDataModel> getDashboard() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsDashboard,
    );
    return DashboardDataModel.fromJson(res['data'] as Map<String, dynamic>);
  }
}
