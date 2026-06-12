// lib/features/task/domain/usecases/create_task_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

part 'create_task_usecase.g.dart';

@riverpod
CreateTaskUsecase createTaskUsecase(Ref ref) =>
    CreateTaskUsecase(ref.watch(taskRepositoryProvider));

class CreateTaskUsecase {
  final TaskRepository _repo;
  const CreateTaskUsecase(this._repo);

  Future<Result<TaskEntity>> call(Map<String, dynamic> data) =>
      _repo.create(data);
}
