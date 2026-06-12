// lib/features/schedule/data/datasources/schedule_remote_datasource.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/schedule_model.dart';

part 'schedule_remote_datasource.g.dart';

@riverpod
ScheduleRemoteDatasource scheduleRemoteDatasource(Ref ref) =>
    ScheduleRemoteDatasource(ref.watch(dioClientProvider));

class ScheduleRemoteDatasource {
  final DioClient _client;
  const ScheduleRemoteDatasource(this._client);

  Future<List<ScheduleModel>> getAll({Map<String, dynamic>? filters}) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.schedules,
      queryParameters: filters,
    );
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ScheduleModel> getById(int id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.schedules}/$id',
    );
    return ScheduleModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<ScheduleModel> create(Map<String, dynamic> data) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.schedules,
      data: data,
    );
    return ScheduleModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<ScheduleModel> update(int id, Map<String, dynamic> data) async {
    final res = await _client.put<Map<String, dynamic>>(
      '${ApiEndpoints.schedules}/$id',
      data: data,
    );
    return ScheduleModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _client.delete('${ApiEndpoints.schedules}/$id');
  }

  Future<List<ScheduleModel>> getToday() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.schedulesToday,
    );
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ScheduleModel>> getWeek() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.schedulesWeek,
    );
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
