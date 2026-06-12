// lib/features/task/domain/usecases/delete_task_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';

part 'delete_task_usecase.g.dart';

@riverpod
DeleteTaskUsecase deleteTaskUsecase(Ref ref) =>
    DeleteTaskUsecase(ref.watch(taskRepositoryProvider));

class DeleteTaskUsecase {
  final TaskRepository _repo;
  const DeleteTaskUsecase(this._repo);

  Future<Result<void>> call(int id) => _repo.delete(id);
}
