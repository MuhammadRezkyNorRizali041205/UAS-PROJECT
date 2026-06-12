// path: lib/features/profile/domain/usecases/update_profile_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

part 'update_profile_usecase.g.dart';

@riverpod
UpdateProfileUsecase updateProfileUsecase(Ref ref) =>
    UpdateProfileUsecase(ref.watch(profileRepositoryProvider));

class UpdateProfileUsecase {
  final ProfileRepository _repo;

  const UpdateProfileUsecase(this._repo);

  Future<Result<UserProfile>> call(Map<String, dynamic> data) =>
      _repo.updateProfile(data);
}
