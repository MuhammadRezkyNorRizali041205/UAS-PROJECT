// lib/features/student_class/data/student_class_repository.dart

import '../../../core/network/dio_client.dart';

class StudentClassRepository {
  const StudentClassRepository(this._client);
  final DioClient _client;

  Future<List<dynamic>> getMyClasses() async {
    return await _client.get<List<dynamic>>('/student/classes',
        fromJson: (json) => json['data'] as List<dynamic>);
  }

  Future<Map<String, dynamic>> getClassDetail(String classId) async {
    return await _client.get<Map<String, dynamic>>('/student/classes/$classId',
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> submitTask(String taskId, {String? content, String? attachmentUrl}) async {
    return await _client.post<Map<String, dynamic>>('/student/class-tasks/$taskId/submit',
        data: {
          if (content != null && content.isNotEmpty) 'content': content,
          if (attachmentUrl != null && attachmentUrl.isNotEmpty) 'attachment_url': attachmentUrl,
        },
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }
}
