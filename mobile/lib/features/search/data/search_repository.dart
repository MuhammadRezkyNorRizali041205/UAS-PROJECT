// lib/features/search/data/search_repository.dart

import '../../../core/network/dio_client.dart';

class SearchRepository {
  const SearchRepository(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> search(String q, {String type = 'all'}) async {
    return await _client.get<Map<String, dynamic>>(
      '/search',
      queryParameters: {'q': q, 'type': type},
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }
}
