// lib/features/schedule/domain/usecases/get_today_schedules_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

part 'get_today_schedules_usecase.g.dart';

@riverpod
GetTodaySchedulesUsecase getTodaySchedulesUsecase(Ref ref) =>
    GetTodaySchedulesUsecase(ref.watch(scheduleRepositoryProvider));

class GetTodaySchedulesUsecase {
  final ScheduleRepository _repo;
  const GetTodaySchedulesUsecase(this._repo);

  Future<Result<List<ScheduleEntity>>> call() => _repo.getToday();
}
