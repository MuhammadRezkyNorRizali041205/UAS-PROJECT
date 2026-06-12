import 'package:flutter/material.dart';

// ─── Streak ───────────────────────────────────────────────────────────────────

class StreakModel {
  final int current;
  final int longest;
  final String? lastActivityDate;
  final bool isActiveToday;
  final String emoji;

  const StreakModel({
    required this.current,
    required this.longest,
    this.lastActivityDate,
    required this.isActiveToday,
    required this.emoji,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) => StreakModel(
        current:          json['current'] as int? ?? 0,
        longest:          json['longest'] as int? ?? 0,
        lastActivityDate: json['last_activity_date'] as String?,
        isActiveToday:    json['is_active_today'] as bool? ?? false,
        emoji:            json['emoji'] as String? ?? '❄️',
      );
}

// ─── Achievement ──────────────────────────────────────────────────────────────

class AchievementModel {
  final int id;
  final String key;
  final String title;
  final String description;
  final String icon;
  final String badgeColor;
  final String category;
  final int pointsReward;
  final bool isEarned;
  final String? earnedAt;

  const AchievementModel({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeColor,
    required this.category,
    required this.pointsReward,
    required this.isEarned,
    this.earnedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
        id:           json['id'] as int,
        key:          json['key'] as String,
        title:        json['title'] as String,
        description:  json['description'] as String,
        icon:         json['icon'] as String? ?? '🏆',
        badgeColor:   json['badge_color'] as String? ?? '#6366F1',
        category:     json['category'] as String? ?? 'engagement',
        pointsReward: json['points_reward'] as int? ?? 0,
        isEarned:     json['is_earned'] as bool? ?? false,
        earnedAt:     json['earned_at'] as String?,
      );

  Color get color {
    try {
      final hex = badgeColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}

class AchievementListModel {
  final List<AchievementModel> earned;
  final List<AchievementModel> locked;

  const AchievementListModel({required this.earned, required this.locked});

  factory AchievementListModel.fromJson(Map<String, dynamic> json) => AchievementListModel(
        earned: (json['earned'] as List<dynamic>? ?? [])
            .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        locked: (json['locked'] as List<dynamic>? ?? [])
            .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Quest ────────────────────────────────────────────────────────────────────

class QuestModel {
  final int id;
  final String key;
  final String title;
  final String description;
  final String icon;
  final int targetCount;
  final int pointsReward;
  final int progress;
  final bool isCompleted;
  final String? completedAt;

  const QuestModel({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetCount,
    required this.pointsReward,
    required this.progress,
    required this.isCompleted,
    this.completedAt,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) => QuestModel(
        id:           json['id'] as int,
        key:          json['key'] as String,
        title:        json['title'] as String,
        description:  json['description'] as String,
        icon:         json['icon'] as String? ?? '⭐',
        targetCount:  json['target_count'] as int? ?? 1,
        pointsReward: json['points_reward'] as int? ?? 0,
        progress:     json['progress'] as int? ?? 0,
        isCompleted:  json['is_completed'] as bool? ?? false,
        completedAt:  json['completed_at'] as String?,
      );

  double get progressFraction =>
      targetCount <= 0 ? 0.0 : (progress / targetCount).clamp(0.0, 1.0);
}

// ─── Gamification Profile ─────────────────────────────────────────────────────

class GamificationProfileModel {
  final int totalPoints;
  final String level;
  final String levelLabel;
  final String levelColor;
  final int currentLevelPoints;
  final int nextLevelThreshold;
  final double progressPercentage;
  final int rank;
  final StreakModel streak;
  final List<AchievementModel> recentAchievements;
  final int todayQuestsCompleted;
  final int todayQuestsTotal;

  const GamificationProfileModel({
    required this.totalPoints,
    required this.level,
    required this.levelLabel,
    required this.levelColor,
    required this.currentLevelPoints,
    required this.nextLevelThreshold,
    required this.progressPercentage,
    required this.rank,
    required this.streak,
    required this.recentAchievements,
    required this.todayQuestsCompleted,
    required this.todayQuestsTotal,
  });

  factory GamificationProfileModel.fromJson(Map<String, dynamic> json) =>
      GamificationProfileModel(
        totalPoints:          json['total_points'] as int? ?? 0,
        level:                json['level'] as String? ?? 'bronze',
        levelLabel:           json['level_label'] as String? ?? 'Bronze',
        levelColor:           json['level_color'] as String? ?? '#CD7F32',
        currentLevelPoints:   json['current_level_points'] as int? ?? 0,
        nextLevelThreshold:   json['next_level_threshold'] as int? ?? 500,
        progressPercentage:   (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
        rank:                 json['rank'] as int? ?? 0,
        streak:               StreakModel.fromJson(json['streak'] as Map<String, dynamic>? ?? {}),
        recentAchievements:   (json['recent_achievements'] as List<dynamic>? ?? [])
            .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        todayQuestsCompleted: json['today_quests_completed'] as int? ?? 0,
        todayQuestsTotal:     json['today_quests_total'] as int? ?? 0,
      );

  Color get levelColorValue {
    try {
      final hex = levelColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFCD7F32);
    }
  }
}

// ─── Leaderboard ─────────────────────────────────────────────────────────────

class LeaderboardEntryModel {
  final int rank;
  final int userId;
  final String name;
  final String? avatarUrl;
  final int totalPoints;
  final String level;
  final String levelLabel;
  final bool isCurrentUser;

  const LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.totalPoints,
    required this.level,
    required this.levelLabel,
    required this.isCurrentUser,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryModel(
        rank:          json['rank'] as int? ?? 0,
        userId:        json['user_id'] as int,
        name:          json['name'] as String,
        avatarUrl:     json['avatar_url'] as String?,
        totalPoints:   json['total_points'] as int? ?? 0,
        level:         json['level'] as String? ?? 'bronze',
        levelLabel:    json['level_label'] as String? ?? 'Bronze',
        isCurrentUser: json['is_current_user'] as bool? ?? false,
      );
}

class LeaderboardModel {
  final List<LeaderboardEntryModel> entries;
  final LeaderboardEntryModel? myRank;
  final String scope;
  final int totalParticipants;

  const LeaderboardModel({
    required this.entries,
    this.myRank,
    required this.scope,
    required this.totalParticipants,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) => LeaderboardModel(
        entries: (json['entries'] as List<dynamic>? ?? [])
            .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        myRank: json['my_rank'] != null
            ? LeaderboardEntryModel.fromJson({
                ...json['my_rank'] as Map<String, dynamic>,
                'user_id': 0,
                'name': '',
                'is_current_user': true,
              })
            : null,
        scope:             json['scope'] as String? ?? 'campus',
        totalParticipants: json['total_participants'] as int? ?? 0,
      );
}

// ─── Point History ────────────────────────────────────────────────────────────

class PointHistoryModel {
  final int id;
  final int points;
  final String type;
  final String activityType;
  final String activityLabel;
  final String? description;
  final String createdAt;

  const PointHistoryModel({
    required this.id,
    required this.points,
    required this.type,
    required this.activityType,
    required this.activityLabel,
    this.description,
    required this.createdAt,
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) => PointHistoryModel(
        id:            json['id'] as int,
        points:        json['points'] as int? ?? 0,
        type:          json['type'] as String? ?? 'earn',
        activityType:  json['activity_type'] as String? ?? '',
        activityLabel: json['activity_label'] as String? ?? '',
        description:   json['description'] as String?,
        createdAt:     json['created_at'] as String? ?? '',
      );
}
