// lib/features/task/domain/usecases/get_upcoming_tasks_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

part 'get_upcoming_tasks_usecase.g.dart';

@riverpod
GetUpcomingTasksUsecase getUpcomingTasksUsecase(Ref ref) =>
    GetUpcomingTasksUsecase(ref.watch(taskRepositoryProvider));

class GetUpcomingTasksUsecase {
  final TaskRepository _repo;
  const GetUpcomingTasksUsecase(this._repo);

  Future<Result<List<TaskEntity>>> call() => _repo.getUpcoming();
}
