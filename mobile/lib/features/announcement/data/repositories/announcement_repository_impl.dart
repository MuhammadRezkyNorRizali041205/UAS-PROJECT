// lib/features/announcement/data/repositories/announcement_repository_impl.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_datasource.dart';
import '../models/announcement_model.dart';

part 'announcement_repository_impl.g.dart';

@riverpod
AnnouncementRepository announcementRepository(Ref ref) =>
    AnnouncementRepositoryImpl(
        ref.watch(announcementRemoteDatasourceProvider));

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDatasource _ds;
  const AnnouncementRepositoryImpl(this._ds);

  @override
  Future<Result<Map<String, dynamic>>> getAnnouncements({
    String category = 'all',
    int page = 1,
  }) async {
    try {
      final data = await _ds.getAnnouncements(category: category, page: page);
      return Success(data);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat pengumuman.');
    }
  }

  @override
  Future<Result<Announcement>> getById(String id) async {
    try {
      final data = await _ds.getById(id);
      return Success(AnnouncementModel.fromJson(data));
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat pengumuman.');
    }
  }
}
