// lib/features/schedule/domain/usecases/create_schedule_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

part 'create_schedule_usecase.g.dart';

@riverpod
CreateScheduleUsecase createScheduleUsecase(Ref ref) =>
    CreateScheduleUsecase(ref.watch(scheduleRepositoryProvider));

class CreateScheduleUsecase {
  final ScheduleRepository _repo;
  const CreateScheduleUsecase(this._repo);

  Future<Result<ScheduleEntity>> call(Map<String, dynamic> data) =>
      _repo.create(data);
}
