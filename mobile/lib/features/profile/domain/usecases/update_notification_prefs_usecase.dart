// path: lib/features/profile/domain/usecases/update_notification_prefs_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../repositories/profile_repository.dart';

part 'update_notification_prefs_usecase.g.dart';

@riverpod
UpdateNotificationPrefsUsecase updateNotificationPrefsUsecase(Ref ref) =>
    UpdateNotificationPrefsUsecase(ref.watch(profileRepositoryProvider));

class UpdateNotificationPrefsUsecase {
  final ProfileRepository _repo;

  const UpdateNotificationPrefsUsecase(this._repo);

  Future<Result<void>> call(Map<String, bool> prefs) =>
      _repo.updateNotificationPrefs(prefs);
}
