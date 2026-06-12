// lib/features/task/data/datasources/task_remote_datasource.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

part 'task_remote_datasource.g.dart';

@riverpod
TaskRemoteDatasource taskRemoteDatasource(Ref ref) =>
    TaskRemoteDatasource(ref.watch(dioClientProvider));

class TaskRemoteDatasource {
  final DioClient _client;
  const TaskRemoteDatasource(this._client);

  Future<List<TaskModel>> getAll({Map<String, dynamic>? filters}) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.tasks,
      queryParameters: filters,
    );
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> getById(int id) async {
    final res =
        await _client.get<Map<String, dynamic>>('${ApiEndpoints.tasks}/$id');
    return TaskModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<TaskModel> create(Map<String, dynamic> data) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.tasks,
      data: data,
    );
    return TaskModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<TaskModel> update(int id, Map<String, dynamic> data) async {
    final res = await _client.put<Map<String, dynamic>>(
      '${ApiEndpoints.tasks}/$id',
      data: data,
    );
    return TaskModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _client.delete('${ApiEndpoints.tasks}/$id');
  }

  Future<TaskModel> updateStatus(int id, String status) async {
    final res = await _client.patch<Map<String, dynamic>>(
      '${ApiEndpoints.tasks}/$id/status',
      data: {'status': status},
    );
    return TaskModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<List<TaskModel>> getUpcoming() async {
    final res = await _client
        .get<Map<String, dynamic>>(ApiEndpoints.tasksUpcoming);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TaskModel>> getOverdue() async {
    final res = await _client
        .get<Map<String, dynamic>>(ApiEndpoints.tasksOverdue);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
