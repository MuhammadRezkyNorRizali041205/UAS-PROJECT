// lib/features/attendance/domain/entities/attendance.dart

class AttendanceSessionEntity {
  final int id;
  final String courseName;
  final String sessionCode;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int radiusM;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isActive;
  final int? attendeeCount;
  final String? creatorName;

  const AttendanceSessionEntity({
    required this.id,
    required this.courseName,
    required this.sessionCode,
    this.location,
    this.latitude,
    this.longitude,
    required this.radiusM,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
    this.attendeeCount,
    this.creatorName,
  });

  bool get isExpired => DateTime.now().isAfter(endsAt);

  Duration get remaining {
    final diff = endsAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}

class AttendanceLogEntity {
  final int id;
  final AttendanceSessionEntity? session;
  final DateTime scannedAt;
  final String scannedAtFormatted;

  const AttendanceLogEntity({
    required this.id,
    this.session,
    required this.scannedAt,
    required this.scannedAtFormatted,
  });
}

class AttendanceStatsEntity {
  final int total;
  final int thisMonth;
  final int thisWeek;

  const AttendanceStatsEntity({
    required this.total,
    required this.thisMonth,
    required this.thisWeek,
  });
}
