// lib/features/schedule/domain/usecases/update_schedule_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

part 'update_schedule_usecase.g.dart';

@riverpod
UpdateScheduleUsecase updateScheduleUsecase(Ref ref) =>
    UpdateScheduleUsecase(ref.watch(scheduleRepositoryProvider));

class UpdateScheduleUsecase {
  final ScheduleRepository _repo;
  const UpdateScheduleUsecase(this._repo);

  Future<Result<ScheduleEntity>> call(int id, Map<String, dynamic> data) =>
      _repo.update(id, data);
}
