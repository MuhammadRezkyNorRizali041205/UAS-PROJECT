class UserEntity {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? emailVerifiedAt;
  final ProfileEntity? profile;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.emailVerifiedAt,
    this.profile,
  });

  bool get isAdmin => role == 'admin' || role == 'org_admin';
  bool get isLecturer => role == 'lecturer';
  bool get isStudent => role == 'student';
  bool get isOrganization => role == 'organization' || role == 'org_admin';
  bool get isVerified => emailVerifiedAt != null;

  String get dashboardRoute => switch (role) {
    'lecturer'     => '/lecturer/dashboard',
    'organization' => '/org/dashboard',
    'org_admin'    => '/org/dashboard',
    'admin'        => '/admin/dashboard',
    _              => '/dashboard',
  };
}

class ProfileEntity {
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final String? faculty;
  final String? major;
  final String? studentId;
  final int? yearEntry;

  const ProfileEntity({
    this.avatarUrl,
    this.bio,
    this.phone,
    this.faculty,
    this.major,
    this.studentId,
    this.yearEntry,
  });
}
