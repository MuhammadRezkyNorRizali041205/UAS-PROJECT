// path: lib/features/profile/data/models/profile_model.dart
import '../../domain/entities/profile.dart';

class ProfileStatsModel extends ProfileStats {
  const ProfileStatsModel({
    required super.totalSchedules,
    required super.totalTasks,
    required super.completedTasks,
    required super.completionRate,
    required super.streak,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      totalSchedules: (json['total_schedules'] as num?)?.toInt() ?? 0,
      totalTasks: (json['total_tasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completed_tasks'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_schedules': totalSchedules,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'completion_rate': completionRate,
        'streak': streak,
      };
}

class NotificationPrefsModel extends NotificationPrefs {
  const NotificationPrefsModel({
    required super.schedule,
    required super.task,
    required super.announcement,
    required super.attendance,
  });

  factory NotificationPrefsModel.fromJson(Map<String, dynamic> json) {
    return NotificationPrefsModel(
      schedule: json['schedule'] as bool? ?? true,
      task: json['task'] as bool? ?? true,
      announcement: json['announcement'] as bool? ?? true,
      attendance: json['attendance'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'schedule': schedule,
        'task': task,
        'announcement': announcement,
        'attendance': attendance,
      };
}

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.avatarUrl,
    required super.nim,
    required super.faculty,
    required super.major,
    required super.semester,
    required super.phone,
    required super.bio,
    required super.stats,
    required super.notificationPrefs,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final profile =
        (json['profile'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      avatarUrl: json['avatar_url'] as String?,
      nim: profile['nim'] as String?,
      faculty: profile['faculty'] as String?,
      major: profile['major'] as String?,
      semester: (profile['semester'] as num?)?.toInt(),
      phone: profile['phone'] as String?,
      bio: profile['bio'] as String?,
      stats: ProfileStatsModel.fromJson(
        (json['stats'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      notificationPrefs: NotificationPrefsModel.fromJson(
        (json['notification_prefs'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatar_url': avatarUrl,
        'profile': {
          'nim': nim,
          'faculty': faculty,
          'major': major,
          'semester': semester,
          'phone': phone,
          'bio': bio,
        },
        'stats': (stats as ProfileStatsModel).toJson(),
        'notification_prefs':
            (notificationPrefs as NotificationPrefsModel).toJson(),
      };

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    String? nim,
    String? faculty,
    String? major,
    int? semester,
    String? phone,
    String? bio,
    ProfileStats? stats,
    NotificationPrefs? notificationPrefs,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nim: nim ?? this.nim,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      semester: semester ?? this.semester,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      stats: stats ?? this.stats,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
    );
  }
}
