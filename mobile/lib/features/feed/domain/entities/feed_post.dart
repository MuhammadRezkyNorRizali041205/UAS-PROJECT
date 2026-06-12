// lib/features/feed/domain/entities/feed_post.dart

class FeedPost {
  const FeedPost({
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
  final String type; // task_completed|streak_milestone|badge_earned|level_up
  final String title;
  final String description;
  final int likesCount;
  final bool isLiked;
  final String visibility;
  final DateTime createdAt;
  final Map<String, dynamic>? achievementData;

  FeedPost copyWith({int? likesCount, bool? isLiked}) => FeedPost(
        id:              id,
        userId:          userId,
        userName:        userName,
        type:            type,
        title:           title,
        description:     description,
        likesCount:      likesCount ?? this.likesCount,
        isLiked:         isLiked ?? this.isLiked,
        visibility:      visibility,
        createdAt:       createdAt,
        achievementData: achievementData,
      );
}
