// lib/features/task/domain/usecases/update_task_status_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

part 'update_task_status_usecase.g.dart';

@riverpod
UpdateTaskStatusUsecase updateTaskStatusUsecase(Ref ref) =>
    UpdateTaskStatusUsecase(ref.watch(taskRepositoryProvider));

class UpdateTaskStatusUsecase {
  final TaskRepository _repo;
  const UpdateTaskStatusUsecase(this._repo);

  Future<Result<TaskEntity>> call(int id, String status) =>
      _repo.updateStatus(id, status);
}
