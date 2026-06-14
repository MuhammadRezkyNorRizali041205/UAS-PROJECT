// lib/features/organization/data/org_repository.dart

import '../../../core/network/dio_client.dart';

class OrgRepository {
  const OrgRepository(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> getDashboard() async {
    return await _client.get<Map<String, dynamic>>('/org/dashboard',
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }

  Future<List<dynamic>> getEvents({String? status}) async {
    return await _client.get<List<dynamic>>('/org/events',
        queryParameters: status != null ? {'status': status} : null,
        fromJson: (json) => json['data'] as List<dynamic>);
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    return await _client.post<Map<String, dynamic>>('/org/events',
        data: data,
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getEventDetail(String eventId) async {
    return await _client.get<Map<String, dynamic>>('/org/events/$eventId',
        fromJson: (json) => json['data'] as Map<String, dynamic>);
  }

  Future<void> publishEvent(String eventId) async {
    await _client.patch<dynamic>('/org/events/$eventId/publish');
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _client.put<dynamic>('/org/events/$eventId', data: data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _client.delete('/org/events/$eventId');
  }

  Future<List<dynamic>> getEventRegistrations(String eventId) async {
    return await _client.get<List<dynamic>>('/org/events/$eventId/registrations',
        fromJson: (json) => json['data'] as List<dynamic>);
  }

  Future<List<dynamic>> getMembers() async {
    return await _client.get<List<dynamic>>('/org/members',
        fromJson: (json) => json['data'] as List<dynamic>);
  }

  Future<void> addMember(String identifier, String role) async {
    await _client.post<dynamic>('/org/members',
        data: {'identifier': identifier, 'role': role});
  }

  Future<void> updateMemberRole(String memberId, String role) async {
    await _client.patch<dynamic>('/org/members/$memberId/role',
        data: {'role': role});
  }

  Future<void> removeMember(String memberId) async {
    await _client.delete('/org/members/$memberId');
  }
}
