// lib/features/notification/data/datasources/notification_remote_datasource.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';

part 'notification_remote_datasource.g.dart';

@riverpod
NotificationRemoteDatasource notificationRemoteDatasource(Ref ref) =>
    NotificationRemoteDatasource(ref.watch(dioClientProvider));

class NotificationRemoteDatasource {
  final DioClient _client;
  const NotificationRemoteDatasource(this._client);

  Future<Map<String, dynamic>> getNotifications({
    String? type,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (type != null && type != 'all') params['type'] = type;
    final res = await _client.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: params,
    );
    return res['data'] as Map<String, dynamic>;
  }

  Future<int> getUnreadCount() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/notifications/unread-count',
    );
    final data = res['data'] as Map<String, dynamic>?;
    return (data?['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int id) async {
    await _client.patch<Map<String, dynamic>>('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _client.patch<Map<String, dynamic>>('/notifications/read-all');
  }

  Future<void> deleteNotification(int id) async {
    await _client.delete('/notifications/$id');
  }
}
