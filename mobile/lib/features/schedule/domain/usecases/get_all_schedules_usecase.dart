// lib/features/schedule/domain/usecases/get_all_schedules_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

part 'get_all_schedules_usecase.g.dart';

@riverpod
GetAllSchedulesUsecase getAllSchedulesUsecase(Ref ref) =>
    GetAllSchedulesUsecase(ref.watch(scheduleRepositoryProvider));

class GetAllSchedulesUsecase {
  final ScheduleRepository _repo;
  const GetAllSchedulesUsecase(this._repo);

  Future<Result<List<ScheduleEntity>>> call({Map<String, dynamic>? filters}) =>
      _repo.getAll(filters: filters);
}
