// lib/features/task/data/repositories/task_repository_impl.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

part 'task_repository_impl.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) =>
    TaskRepositoryImpl(ref.watch(taskRemoteDatasourceProvider));

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource _datasource;
  const TaskRepositoryImpl(this._datasource);

  @override
  Future<Result<List<TaskEntity>>> getAll(
      {Map<String, dynamic>? filters}) async {
    try {
      return Success(await _datasource.getAll(filters: filters));
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat tugas.');
    }
  }

  @override
  Future<Result<TaskEntity>> getById(int id) async {
    try {
      return Success(await _datasource.getById(id));
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Tugas tidak ditemukan.');
    }
  }

  @override
  Future<Result<TaskEntity>> create(Map<String, dynamic> data) async {
    try {
      return Success(await _datasource.create(data));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal menyimpan tugas.');
    }
  }

  @override
  Future<Result<TaskEntity>> update(int id, Map<String, dynamic> data) async {
    try {
      return Success(await _datasource.update(id, data));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memperbarui tugas.');
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
      return const Failure('Gagal menghapus tugas.');
    }
  }

  @override
  Future<Result<TaskEntity>> updateStatus(int id, String status) async {
    try {
      return Success(await _datasource.updateStatus(id, status));
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memperbarui status tugas.');
    }
  }

  @override
  Future<Result<List<TaskEntity>>> getUpcoming() async {
    try {
      return Success(await _datasource.getUpcoming());
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat tugas mendatang.');
    }
  }

  @override
  Future<Result<List<TaskEntity>>> getOverdue() async {
    try {
      return Success(await _datasource.getOverdue());
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat tugas terlambat.');
    }
  }
}
