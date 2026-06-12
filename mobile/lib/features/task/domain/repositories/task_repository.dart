// lib/features/task/domain/repositories/task_repository.dart
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Result<List<TaskEntity>>> getAll({Map<String, dynamic>? filters});
  Future<Result<TaskEntity>> getById(int id);
  Future<Result<TaskEntity>> create(Map<String, dynamic> data);
  Future<Result<TaskEntity>> update(int id, Map<String, dynamic> data);
  Future<Result<void>> delete(int id);
  Future<Result<TaskEntity>> updateStatus(int id, String status);
  Future<Result<List<TaskEntity>>> getUpcoming();
  Future<Result<List<TaskEntity>>> getOverdue();
}
