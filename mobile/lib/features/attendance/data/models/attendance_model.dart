// lib/features/attendance/data/models/attendance_model.dart

import '../../domain/entities/attendance.dart';

class AttendanceSessionModel extends AttendanceSessionEntity {
  const AttendanceSessionModel({
    required super.id,
    required super.courseName,
    required super.sessionCode,
    super.location,
    super.latitude,
    super.longitude,
    required super.radiusM,
    required super.startsAt,
    required super.endsAt,
    required super.isActive,
    super.attendeeCount,
    super.creatorName,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) =>
      AttendanceSessionModel(
        id:             json['id'] as int,
        courseName:     json['course_name'] as String,
        sessionCode:    json['session_code'] as String,
        location:       json['location'] as String?,
        latitude:       (json['latitude'] as num?)?.toDouble(),
        longitude:      (json['longitude'] as num?)?.toDouble(),
        radiusM:        (json['radius_m'] as num?)?.toInt() ?? 100,
        startsAt:       DateTime.parse(json['starts_at'] as String),
        endsAt:         DateTime.parse(json['ends_at'] as String),
        isActive:       json['is_active'] as bool,
        attendeeCount:  json['attendee_count'] as int?,
        creatorName:    (json['creator'] as Map<String, dynamic>?)?['name'] as String?,
      );
}

class AttendanceLogModel extends AttendanceLogEntity {
  const AttendanceLogModel({
    required super.id,
    super.session,
    required super.scannedAt,
    required super.scannedAtFormatted,
  });

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    final sessionJson = json['session'] as Map<String, dynamic>?;
    return AttendanceLogModel(
      id:                 json['id'] as int,
      scannedAt:          DateTime.parse(json['scanned_at'] as String),
      scannedAtFormatted: json['scanned_at_formatted'] as String? ?? '',
      session: sessionJson != null
          ? AttendanceSessionModel(
              id:          sessionJson['id'] as int,
              courseName:  sessionJson['course_name'] as String,
              sessionCode: '',
              radiusM:     100,
              startsAt:    DateTime.parse(sessionJson['starts_at'] as String),
              endsAt:      DateTime.parse(sessionJson['ends_at'] as String),
              isActive:    false,
              location:    sessionJson['location'] as String?,
            )
          : null,
    );
  }
}

class AttendanceStatsModel extends AttendanceStatsEntity {
  const AttendanceStatsModel({
    required super.total,
    required super.thisMonth,
    required super.thisWeek,
  });

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) =>
      AttendanceStatsModel(
        total:     (json['total'] as num?)?.toInt() ?? 0,
        thisMonth: (json['thisMonth'] as num?)?.toInt() ?? 0,
        thisWeek:  (json['thisWeek'] as num?)?.toInt() ?? 0,
      );
}
