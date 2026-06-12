// lib/features/announcement/data/datasources/announcement_remote_datasource.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

part 'announcement_remote_datasource.g.dart';

@riverpod
AnnouncementRemoteDatasource announcementRemoteDatasource(Ref ref) =>
    AnnouncementRemoteDatasource(ref.watch(dioClientProvider));

class AnnouncementRemoteDatasource {
  final DioClient _client;
  const AnnouncementRemoteDatasource(this._client);

  Future<Map<String, dynamic>> getAnnouncements({
    String category = 'all',
    int page = 1,
  }) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.announcements,
      queryParameters: {
        if (category != 'all') 'category': category,
        'page': page,
      },
    );
    // res['data'] is the pagination wrapper from Laravel
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final res = await _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.announcements}/$id',
    );
    return res['data'] as Map<String, dynamic>;
  }
}
