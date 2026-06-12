// lib/features/schedule/data/repositories/schedule_repository_impl.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

part 'schedule_repository_impl.g.dart';

@riverpod
ScheduleRepository scheduleRepository(Ref ref) =>
    ScheduleRepositoryImpl(ref.watch(scheduleRemoteDatasourceProvider));

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDatasource _datasource;
  const ScheduleRepositoryImpl(this._datasource);

  @override
  Future<Result<List<ScheduleEntity>>> getAll(
      {Map<String, dynamic>? filters}) async {
    try {
      final data = await _datasource.getAll(filters: filters);
      return Success(data);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat jadwal.');
    }
  }

  @override
  Future<Result<ScheduleEntity>> getById(int id) async {
    try {
      final data = await _datasource.getById(id);
      return Success(data);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Jadwal tidak ditemukan.');
    }
  }

  @override
  Future<Result<ScheduleEntity>> create(Map<String, dynamic> data) async {
    try {
      final schedule = await _datasource.create(data);
      return Success(schedule);
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal menyimpan jadwal.');
    }
  }

  @override
  Future<Result<ScheduleEntity>> update(
      int id, Map<String, dynamic> data) async {
    try {
      final schedule = await _datasource.update(id, data);
      return Success(schedule);
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memperbarui jadwal.');
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await _datasource.delete(id);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal menghapus jadwal.');
    }
  }

  @override
  Future<Result<List<ScheduleEntity>>> getToday() async {
    try {
      final data = await _datasource.getToday();
      return Success(data);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat jadwal hari ini.');
    }
  }

  @override
  Future<Result<List<ScheduleEntity>>> getWeek() async {
    try {
      final data = await _datasource.getWeek();
      return Success(data);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat jadwal minggu ini.');
    }
  }
}
