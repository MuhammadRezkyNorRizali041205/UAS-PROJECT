// lib/features/attendance/domain/repositories/attendance_repository.dart

import '../../../../core/errors/failures.dart';
import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Result<AttendanceSessionEntity>> createSession(Map<String, dynamic> data);
  Future<Result<AttendanceSessionEntity>> getSession(String code);
  Future<Result<AttendanceLogEntity>> scan(String code);
  Future<Result<List<AttendanceLogEntity>>> getHistory();
  Future<Result<AttendanceStatsEntity>> getStats();
}
