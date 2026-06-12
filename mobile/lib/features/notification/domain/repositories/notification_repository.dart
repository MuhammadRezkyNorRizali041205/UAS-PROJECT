// lib/features/notification/domain/repositories/notification_repository.dart

import '../../../../core/errors/failures.dart';

abstract class NotificationRepository {
  Future<Result<Map<String, dynamic>>> getNotifications({
    String? type,
    int page,
  });
  Future<Result<int>> getUnreadCount();
  Future<Result<void>> markRead(int id);
  Future<Result<void>> markAllRead();
  Future<Result<void>> deleteNotification(int id);
}
