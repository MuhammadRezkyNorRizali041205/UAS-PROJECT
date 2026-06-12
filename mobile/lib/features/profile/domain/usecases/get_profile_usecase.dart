// path: lib/features/profile/domain/usecases/get_profile_usecase.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

part 'get_profile_usecase.g.dart';

@riverpod
GetProfileUsecase getProfileUsecase(Ref ref) =>
    GetProfileUsecase(ref.watch(profileRepositoryProvider));

class GetProfileUsecase {
  final ProfileRepository _repo;

  const GetProfileUsecase(this._repo);

  Future<Result<UserProfile>> call() => _repo.getProfile();
}
