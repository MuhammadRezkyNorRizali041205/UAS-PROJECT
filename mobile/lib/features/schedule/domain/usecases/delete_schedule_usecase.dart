// lib/features/schedule/domain/usecases/delete_schedule_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../repositories/schedule_repository.dart';

part 'delete_schedule_usecase.g.dart';

@riverpod
DeleteScheduleUsecase deleteScheduleUsecase(Ref ref) =>
    DeleteScheduleUsecase(ref.watch(scheduleRepositoryProvider));

class DeleteScheduleUsecase {
  final ScheduleRepository _repo;
  const DeleteScheduleUsecase(this._repo);

  Future<Result<void>> call(int id) => _repo.delete(id);
}
