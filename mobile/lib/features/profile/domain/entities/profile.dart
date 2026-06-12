// path: lib/features/profile/domain/entities/profile.dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? nim;
  final String? faculty;
  final String? major;
  final int? semester;
  final String? phone;
  final String? bio;
  final ProfileStats stats;
  final NotificationPrefs notificationPrefs;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.nim,
    required this.faculty,
    required this.major,
    required this.semester,
    required this.phone,
    required this.bio,
    required this.stats,
    required this.notificationPrefs,
  });
}

class ProfileStats {
  final int totalSchedules;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final int streak;

  const ProfileStats({
    required this.totalSchedules,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.streak,
  });
}

class NotificationPrefs {
  final bool schedule;
  final bool task;
  final bool announcement;
  final bool attendance;

  const NotificationPrefs({
    required this.schedule,
    required this.task,
    required this.announcement,
    required this.attendance,
  });
}
