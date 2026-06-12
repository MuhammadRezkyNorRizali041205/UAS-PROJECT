// path: lib/features/profile/presentation/providers/profile_provider.dart
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/update_notification_prefs_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile> build() async {
    final result = await ref.read(getProfileUsecaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (msg, _) => throw Exception(msg),
    );
  }

  Future<String?> refreshProfile() async {
    state = const AsyncLoading();
    final result = await ref.read(getProfileUsecaseProvider).call();

    return result.when(
      success: (data) {
        state = AsyncData(data);
        return null;
      },
      failure: (msg, _) {
        state = AsyncError(Exception(msg), StackTrace.current);
        return msg;
      },
    );
  }

  Future<String?> updateProfile(Map<String, dynamic> data) async {
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current);
    }

    final result = await ref.read(updateProfileUsecaseProvider).call(data);
    return result.when(
      success: (updated) {
        state = AsyncData(updated);
        return null;
      },
      failure: (msg, _) => msg,
    );
  }

  Future<String?> updateAvatar(XFile file) async {
    final current = state.asData?.value;
    if (current == null) return 'Profil belum siap.';

    final result = await ref.read(updateAvatarUsecaseProvider).call(file);

    return result.when(
      success: (_) async {
        await refreshProfile();
        return null;
      },
      failure: (msg, _) => msg,
    );
  }

  Future<String?> updateNotificationPrefs(Map<String, bool> prefs) async {
    final current = state.asData?.value;
    if (current == null) return 'Profil belum siap.';

    final result =
        await ref.read(updateNotificationPrefsUsecaseProvider).call(prefs);

    return result.when(
      success: (_) async {
        state = AsyncData(UserProfile(
          id: current.id,
          name: current.name,
          email: current.email,
          role: current.role,
          avatarUrl: current.avatarUrl,
          nim: current.nim,
          faculty: current.faculty,
          major: current.major,
          semester: current.semester,
          phone: current.phone,
          bio: current.bio,
          stats: current.stats,
          notificationPrefs: NotificationPrefs(
            schedule: prefs['schedule'] ?? current.notificationPrefs.schedule,
            task: prefs['task'] ?? current.notificationPrefs.task,
            announcement:
                prefs['announcement'] ?? current.notificationPrefs.announcement,
            attendance:
                prefs['attendance'] ?? current.notificationPrefs.attendance,
          ),
        ));
        return null;
      },
      failure: (msg, _) => msg,
    );
  }
}
