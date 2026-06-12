import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    super.emailVerifiedAt,
    super.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool? ?? true,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'is_active': isActive,
        'email_verified_at': emailVerifiedAt?.toIso8601String(),
      };
}

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    super.avatarUrl,
    super.bio,
    super.phone,
    super.faculty,
    super.major,
    super.studentId,
    super.yearEntry,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      faculty: json['faculty'] as String?,
      major: json['major'] as String?,
      studentId: json['student_id'] as String?,
      yearEntry: json['year_entry'] as int?,
    );
  }
}
