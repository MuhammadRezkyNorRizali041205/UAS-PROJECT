// lib/features/lecturer/data/lecturer_repository.dart

import '../../../core/network/dio_client.dart';

class LecturerRepository {
  const LecturerRepository(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> getDashboard() async {
    final data = await _client.get<Map<String, dynamic>>('/lecturer/dashboard',
        fromJson: (json) => json['data'] as Map<String, dynamic>);
    return data;
  }

  Future<List<dynamic>> getClasses() async {
    return await _client.get<List<dynamic>>('/lecturer/classes',
        fromJson: (json) => json['data'] as List<dynamic>);
  }

  Future<Map<String, dynamic>> getClassDetail(String classId) async {
    return await _client.get<Map<String, dynamic>>('/lecturer/classes/$classId',
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> createClass(Map<String, dynamic> data) async {
    return await _client.post<Map<String, dynamic>>('/lecturer/classes',
        data: data,
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }

  Future<void> enrollStudent(String classId, String identifier) async {
    await _client.post<dynamic>('/lecturer/classes/$classId/enroll',
        data: {'identifier': identifier});
  }

  Future<List<dynamic>> getTasks(String classId) async {
    return await _client.get<List<dynamic>>('/lecturer/classes/$classId/tasks',
        fromJson: (json) => json['data'] as List<dynamic>);
  }

  Future<Map<String, dynamic>> createTask(String classId, Map<String, dynamic> data) async {
    return await _client.post<Map<String, dynamic>>('/lecturer/classes/$classId/tasks',
        data: data,
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }

  Future<List<dynamic>> getSubmissions(String taskId, {String? filter}) async {
    return await _client.get<List<dynamic>>(
        '/lecturer/tasks/$taskId/submissions',
        queryParameters: filter != null ? {'filter': filter} : null,
        fromJson: (json) => json['data'] as List<dynamic>);
  }

  Future<void> gradeSubmission(String submissionId, int score, String? feedback) async {
    await _client.patch<dynamic>('/lecturer/submissions/$submissionId/grade', data: {
      'score': score,
      if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
    });
  }

  Future<Map<String, dynamic>> getStudentProgress(String classId, String studentId) async {
    return await _client.get<Map<String, dynamic>>(
        '/lecturer/classes/$classId/students/$studentId/progress',
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }
}
