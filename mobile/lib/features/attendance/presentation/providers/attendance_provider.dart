// lib/features/attendance/presentation/providers/attendance_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance.dart';

part 'attendance_provider.g.dart';

// ─── Stats ────────────────────────────────────────────────────────────────────
@riverpod
Future<AttendanceStatsEntity> attendanceStats(Ref ref) async {
  final result = await ref.read(attendanceRepositoryProvider).getStats();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── History ──────────────────────────────────────────────────────────────────
@riverpod
Future<List<AttendanceLogEntity>> attendanceHistory(Ref ref) async {
  final result = await ref.read(attendanceRepositoryProvider).getHistory();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── Create session notifier ──────────────────────────────────────────────────
@riverpod
class CreateSession extends _$CreateSession {
  @override
  AsyncValue<AttendanceSessionEntity?> build() => const AsyncData(null);

  Future<String?> create(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result =
        await ref.read(attendanceRepositoryProvider).createSession(data);
    return result.when(
      success: (session) {
        state = AsyncData(session);
        return null;
      },
      failure: (msg, _) {
        state = const AsyncData(null);
        return msg;
      },
    );
  }

  void reset() => state = const AsyncData(null);
}

// ─── Scan notifier ────────────────────────────────────────────────────────────
@riverpod
class ScanQr extends _$ScanQr {
  @override
  AsyncValue<AttendanceLogEntity?> build() => const AsyncData(null);

  Future<String?> scan(String code) async {
    state = const AsyncLoading();
    final result = await ref.read(attendanceRepositoryProvider).scan(code);
    return result.when(
      success: (log) {
        state = AsyncData(log);
        ref.invalidate(attendanceHistoryProvider);
        ref.invalidate(attendanceStatsProvider);
        return null;
      },
      failure: (msg, _) {
        state = const AsyncData(null);
        return msg;
      },
    );
  }

  void reset() => state = const AsyncData(null);
}
