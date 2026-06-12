// lib/features/notification/domain/entities/app_notification.dart

class AppNotification {
  final int id;
  final String type;
  final String typeLabel;
  final String title;
  final String body;
  final bool isRead;
  final String? readAt;
  final String? relativeTime;
  final String? createdAt;
  final Map<String, dynamic>? meta;

  const AppNotification({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.title,
    required this.body,
    required this.isRead,
    this.readAt,
    this.relativeTime,
    this.createdAt,
    this.meta,
  });
}
