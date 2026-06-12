// lib/features/task/domain/usecases/update_task_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

part 'update_task_usecase.g.dart';

@riverpod
UpdateTaskUsecase updateTaskUsecase(Ref ref) =>
    UpdateTaskUsecase(ref.watch(taskRepositoryProvider));

class UpdateTaskUsecase {
  final TaskRepository _repo;
  const UpdateTaskUsecase(this._repo);

  Future<Result<TaskEntity>> call(int id, Map<String, dynamic> data) =>
      _repo.update(id, data);
}
