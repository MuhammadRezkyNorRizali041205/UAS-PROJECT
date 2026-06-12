// lib/features/announcement/domain/entities/announcement.dart

class Announcement {
  final int id;
  final String title;
  final String contentPreview;
  final String? body;
  final String category;
  final String categoryLabel;
  final String categoryColor;
  final bool isUrgent;
  final String authorName;
  final String? publishedAt;
  final String? publishedAtFormatted;
  final String? expiresAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.contentPreview,
    this.body,
    required this.category,
    required this.categoryLabel,
    required this.categoryColor,
    required this.isUrgent,
    required this.authorName,
    this.publishedAt,
    this.publishedAtFormatted,
    this.expiresAt,
  });
}
