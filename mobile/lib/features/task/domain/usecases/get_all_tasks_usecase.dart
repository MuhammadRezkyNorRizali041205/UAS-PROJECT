// lib/features/task/domain/usecases/get_all_tasks_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

part 'get_all_tasks_usecase.g.dart';

@riverpod
GetAllTasksUsecase getAllTasksUsecase(Ref ref) =>
    GetAllTasksUsecase(ref.watch(taskRepositoryProvider));

class GetAllTasksUsecase {
  final TaskRepository _repo;
  const GetAllTasksUsecase(this._repo);

  Future<Result<List<TaskEntity>>> call({Map<String, dynamic>? filters}) =>
      _repo.getAll(filters: filters);
}
