// lib/features/schedule/domain/repositories/schedule_repository.dart
import '../../../../core/errors/failures.dart';
import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<Result<List<ScheduleEntity>>> getAll({Map<String, dynamic>? filters});
  Future<Result<ScheduleEntity>> getById(int id);
  Future<Result<ScheduleEntity>> create(Map<String, dynamic> data);
  Future<Result<ScheduleEntity>> update(int id, Map<String, dynamic> data);
  Future<Result<void>> delete(int id);
  Future<Result<List<ScheduleEntity>>> getToday();
  Future<Result<List<ScheduleEntity>>> getWeek();
}
