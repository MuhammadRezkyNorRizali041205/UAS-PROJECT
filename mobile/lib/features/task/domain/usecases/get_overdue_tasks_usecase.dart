// lib/features/task/domain/usecases/get_overdue_tasks_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

part 'get_overdue_tasks_usecase.g.dart';

@riverpod
GetOverdueTasksUsecase getOverdueTasksUsecase(Ref ref) =>
    GetOverdueTasksUsecase(ref.watch(taskRepositoryProvider));

class GetOverdueTasksUsecase {
  final TaskRepository _repo;
  const GetOverdueTasksUsecase(this._repo);

  Future<Result<List<TaskEntity>>> call() => _repo.getOverdue();
}
