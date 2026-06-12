// path: lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

part 'profile_repository_impl.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepositoryImpl(ref.watch(profileRemoteDatasourceProvider));

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _datasource;

  const ProfileRepositoryImpl(this._datasource);

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      return Success(await _datasource.getProfile());
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memuat profil.');
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(Map<String, dynamic> data) async {
    try {
      return Success(await _datasource.updateProfile(data));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal memperbarui profil.');
    }
  }

  @override
  Future<Result<String>> updateAvatar(XFile file) async {
    try {
      return Success(await _datasource.updateAvatar(file));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal mengunggah avatar.');
    }
  }

  @override
  Future<Result<void>> updateNotificationPrefs(Map<String, bool> prefs) async {
    try {
      await _datasource.updateNotificationPrefs(prefs);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (_) {
      return const Failure('Gagal menyimpan preferensi notifikasi.');
    }
  }
}
