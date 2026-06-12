// lib/features/notification/data/repositories/notification_repository_impl.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

part 'notification_repository_impl.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepositoryImpl(
        ref.watch(notificationRemoteDatasourceProvider));

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _ds;
  const NotificationRepositoryImpl(this._ds);

  @override
  Future<Result<Map<String, dynamic>>> getNotifications({
    String? type,
    int page = 1,
  }) async {
    try {
      final data = await _ds.getNotifications(type: type, page: page);
      return Success(data);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat notifikasi.');
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final count = await _ds.getUnreadCount();
      return Success(count);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat jumlah notifikasi.');
    }
  }

  @override
  Future<Result<void>> markRead(int id) async {
    try {
      await _ds.markRead(id);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal menandai notifikasi.');
    }
  }

  @override
  Future<Result<void>> markAllRead() async {
    try {
      await _ds.markAllRead();
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal menandai semua notifikasi.');
    }
  }

  @override
  Future<Result<void>> deleteNotification(int id) async {
    try {
      await _ds.deleteNotification(id);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal menghapus notifikasi.');
    }
  }
}
