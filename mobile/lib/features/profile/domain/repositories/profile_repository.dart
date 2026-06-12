// path: lib/features/profile/domain/repositories/profile_repository.dart
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getProfile();
  Future<Result<UserProfile>> updateProfile(Map<String, dynamic> data);
  Future<Result<String>> updateAvatar(XFile file);
  Future<Result<void>> updateNotificationPrefs(Map<String, bool> prefs);
}
