// lib/features/task/presentation/providers/task_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_all_tasks_usecase.dart';
import '../../domain/usecases/get_overdue_tasks_usecase.dart';
import '../../domain/usecases/get_upcoming_tasks_usecase.dart';
import '../../domain/usecases/update_task_status_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

part 'task_provider.g.dart';

// ─── All tasks list (Semua tab) ───────────────────────────────────────────────
@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<TaskEntity>> build() async {
    final result = await ref.read(getAllTasksUsecaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg, _) => throw Exception(msg),
    );
  }

  Future<String?> createTask(Map<String, dynamic> data) async {
    final result = await ref.read(createTaskUsecaseProvider).call(data);
    return result.when(
      success: (_) { _invalidateAll(); return null; },
      failure: (msg, _) => msg,
    );
  }

  Future<String?> updateTask(int id, Map<String, dynamic> data) async {
    final result = await ref.read(updateTaskUsecaseProvider).call(id, data);
    return result.when(
      success: (_) { _invalidateAll(); return null; },
      failure: (msg, _) => msg,
    );
  }

  Future<String?> deleteTask(int id) async {
    final result = await ref.read(deleteTaskUsecaseProvider).call(id);
    return result.when(
      success: (_) { _invalidateAll(); return null; },
      failure: (msg, _) => msg,
    );
  }

  Future<String?> updateStatus(int id, String status) async {
    final result =
        await ref.read(updateTaskStatusUsecaseProvider).call(id, status);
    return result.when(
      success: (_) { _invalidateAll(); return null; },
      failure: (msg, _) => msg,
    );
  }

  void _invalidateAll() {
    ref.invalidateSelf();
    ref.invalidate(upcomingTasksProvider);
    ref.invalidate(overdueTasksProvider);
  }
}

// ─── Upcoming tasks ───────────────────────────────────────────────────────────
@riverpod
Future<List<TaskEntity>> upcomingTasks(Ref ref) async {
  final result = await ref.read(getUpcomingTasksUsecaseProvider).call();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── Overdue tasks ────────────────────────────────────────────────────────────
@riverpod
Future<List<TaskEntity>> overdueTasks(Ref ref) async {
  final result = await ref.read(getOverdueTasksUsecaseProvider).call();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── Task by ID (for edit form pre-population) ────────────────────────────────
@riverpod
Future<TaskEntity> taskById(Ref ref, int id) async {
  final cached = ref
      .watch(taskListProvider)
      .asData
      ?.value
      .where((t) => t.id == id)
      .firstOrNull;
  if (cached != null) return cached;

  final result = await ref.read(taskRepositoryProvider).getById(id);
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}
