// lib/features/attendance/data/datasources/attendance_remote_datasource.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/attendance_model.dart';

part 'attendance_remote_datasource.g.dart';

@riverpod
AttendanceRemoteDatasource attendanceRemoteDatasource(Ref ref) =>
    AttendanceRemoteDatasource(ref.watch(dioClientProvider));

class AttendanceRemoteDatasource {
  final DioClient _client;
  const AttendanceRemoteDatasource(this._client);

  Future<AttendanceSessionModel> createSession(Map<String, dynamic> data) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.attendanceSessions,
      data: data,
    );
    return AttendanceSessionModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<AttendanceSessionModel> getSession(String code) async {
    final res = await _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.attendanceSessions}/$code',
    );
    return AttendanceSessionModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<AttendanceLogModel> scan(String code) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.attendanceScan,
      data: {'code': code},
    );
    return AttendanceLogModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<List<AttendanceLogModel>> getHistory() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.attendanceHistory,
    );
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => AttendanceLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceStatsModel> getStats() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.attendanceStats,
    );
    return AttendanceStatsModel.fromJson(res['data'] as Map<String, dynamic>);
  }
}
