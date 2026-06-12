// lib/features/schedule/domain/usecases/get_week_schedules_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

part 'get_week_schedules_usecase.g.dart';

@riverpod
GetWeekSchedulesUsecase getWeekSchedulesUsecase(Ref ref) =>
    GetWeekSchedulesUsecase(ref.watch(scheduleRepositoryProvider));

class GetWeekSchedulesUsecase {
  final ScheduleRepository _repo;
  const GetWeekSchedulesUsecase(this._repo);

  Future<Result<List<ScheduleEntity>>> call() => _repo.getWeek();
}
