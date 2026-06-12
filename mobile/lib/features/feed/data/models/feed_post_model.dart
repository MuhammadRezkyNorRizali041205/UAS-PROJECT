// lib/features/feed/data/models/feed_post_model.dart

import '../../domain/entities/feed_post.dart';

class FeedPostModel {
  const FeedPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.title,
    required this.description,
    required this.likesCount,
    required this.isLiked,
    required this.visibility,
    required this.createdAt,
    this.achievementData,
  });

  final String id;
  final int userId;
  final String userName;
  final String type;
  final String title;
  final String description;
  final int likesCount;
  final bool isLiked;
  final String visibility;
  final DateTime createdAt;
  final Map<String, dynamic>? achievementData;

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return FeedPostModel(
      id:              json['id'] as String,
      userId:          (user['id'] as num?)?.toInt() ?? 0,
      userName:        (user['name'] as String?) ?? '',
      type:            (json['type'] as String?) ?? 'task_completed',
      title:           (json['title'] as String?) ?? '',
      description:     (json['description'] as String?) ?? '',
      likesCount:      (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked:         (json['is_liked'] as bool?) ?? false,
      visibility:      (json['visibility'] as String?) ?? 'public',
      createdAt:       DateTime.parse(json['created_at'] as String),
      achievementData: json['achievement_data'] as Map<String, dynamic>?,
    );
  }

  FeedPost toEntity() => FeedPost(
        id:              id,
        userId:          userId,
        userName:        userName,
        type:            type,
        title:           title,
        description:     description,
        likesCount:      likesCount,
        isLiked:         isLiked,
        visibility:      visibility,
        createdAt:       createdAt,
        achievementData: achievementData,
      );
}
