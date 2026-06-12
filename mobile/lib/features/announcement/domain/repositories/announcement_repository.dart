// lib/features/announcement/domain/repositories/announcement_repository.dart

import '../../../../core/errors/failures.dart';
import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<Result<Map<String, dynamic>>> getAnnouncements({
    String category = 'all',
    int page = 1,
  });

  Future<Result<Announcement>> getById(String id);
}
