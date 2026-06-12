// lib/features/attendance/data/repositories/attendance_repository_impl.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

part 'attendance_repository_impl.g.dart';

@riverpod
AttendanceRepository attendanceRepository(Ref ref) =>
    AttendanceRepositoryImpl(ref.watch(attendanceRemoteDatasourceProvider));

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDatasource _ds;
  const AttendanceRepositoryImpl(this._ds);

  @override
  Future<Result<AttendanceSessionEntity>> createSession(
      Map<String, dynamic> data) async {
    try {
      return Success(await _ds.createSession(data));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal membuat sesi presensi.');
    }
  }

  @override
  Future<Result<AttendanceSessionEntity>> getSession(String code) async {
    try {
      return Success(await _ds.getSession(code));
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Sesi tidak ditemukan.');
    }
  }

  @override
  Future<Result<AttendanceLogEntity>> scan(String code) async {
    try {
      return Success(await _ds.scan(code));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal melakukan presensi.');
    }
  }

  @override
  Future<Result<List<AttendanceLogEntity>>> getHistory() async {
    try {
      return Success(await _ds.getHistory());
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat riwayat presensi.');
    }
  }

  @override
  Future<Result<AttendanceStatsEntity>> getStats() async {
    try {
      return Success(await _ds.getStats());
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat statistik.');
    }
  }
}
