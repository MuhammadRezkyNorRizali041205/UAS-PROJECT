// lib/features/announcement/data/models/announcement_model.dart

import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.contentPreview,
    super.body,
    required super.category,
    required super.categoryLabel,
    required super.categoryColor,
    required super.isUrgent,
    required super.authorName,
    super.publishedAt,
    super.publishedAtFormatted,
    super.expiresAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id:                   (json['id'] as num).toInt(),
      title:                json['title'] as String? ?? '',
      contentPreview:       json['content_preview'] as String? ?? '',
      body:                 json['body'] as String?,
      category:             json['category'] as String? ?? 'general',
      categoryLabel:        json['category_label'] as String? ?? 'Umum',
      categoryColor:        json['category_color'] as String? ?? '#9CA3AF',
      isUrgent:             json['is_urgent'] as bool? ?? false,
      authorName:           json['author_name'] as String? ?? 'Admin',
      publishedAt:          json['published_at'] as String?,
      publishedAtFormatted: json['published_at_formatted'] as String?,
      expiresAt:            json['expires_at'] as String?,
    );
  }
}
