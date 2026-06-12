// lib/features/notification/data/models/notification_model.dart

import '../../domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.typeLabel,
    required super.title,
    required super.body,
    required super.isRead,
    super.readAt,
    super.relativeTime,
    super.createdAt,
    super.meta,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? '',
      typeLabel: json['type_label'] as String? ?? 'Notifikasi',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      relativeTime: json['relative_time'] as String?,
      createdAt: json['created_at'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}
