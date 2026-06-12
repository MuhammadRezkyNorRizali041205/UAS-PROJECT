// lib/features/schedule/presentation/providers/schedule_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/usecases/create_schedule_usecase.dart';
import '../../domain/usecases/delete_schedule_usecase.dart';
import '../../domain/usecases/get_all_schedules_usecase.dart';
import '../../domain/usecases/get_today_schedules_usecase.dart';
import '../../domain/usecases/get_week_schedules_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';

part 'schedule_provider.g.dart';

// ─── All schedules (Semua tab) ─────────────────────────────────────────────
@riverpod
class ScheduleList extends _$ScheduleList {
  @override
  Future<List<ScheduleEntity>> build() async {
    final result = await ref.read(getAllSchedulesUsecaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg, _) => throw Exception(msg),
    );
  }

  Future<String?> createSchedule(Map<String, dynamic> data) async {
    final result = await ref.read(createScheduleUsecaseProvider).call(data);
    return result.when(
      success: (_) {
        _invalidateAll();
        return null;
      },
      failure: (msg, _) => msg,
    );
  }

  Future<String?> updateSchedule(int id, Map<String, dynamic> data) async {
    final result =
        await ref.read(updateScheduleUsecaseProvider).call(id, data);
    return result.when(
      success: (_) {
        _invalidateAll();
        return null;
      },
      failure: (msg, _) => msg,
    );
  }

  Future<String?> deleteSchedule(int id) async {
    final result = await ref.read(deleteScheduleUsecaseProvider).call(id);
    return result.when(
      success: (_) {
        _invalidateAll();
        return null;
      },
      failure: (msg, _) => msg,
    );
  }

  void _invalidateAll() {
    ref.invalidateSelf();
    ref.invalidate(todaySchedulesProvider);
    ref.invalidate(weekSchedulesProvider);
  }
}

// ─── Today's schedules (Hari Ini tab) ─────────────────────────────────────
@riverpod
Future<List<ScheduleEntity>> todaySchedules(Ref ref) async {
  final result = await ref.read(getTodaySchedulesUsecaseProvider).call();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── This week's schedules (Minggu Ini tab) ────────────────────────────────
@riverpod
Future<List<ScheduleEntity>> weekSchedules(Ref ref) async {
  final result = await ref.read(getWeekSchedulesUsecaseProvider).call();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── Schedule by ID (for edit form pre-population) ─────────────────────────
@riverpod
Future<ScheduleEntity> scheduleById(Ref ref, int id) async {
  // Check list cache first
  final listState = ref.watch(scheduleListProvider);
  final cached = listState.asData?.value.where((s) => s.id == id).firstOrNull;
  if (cached != null) return cached;

  final result = await ref.read(scheduleRepositoryProvider).getById(id);
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}
