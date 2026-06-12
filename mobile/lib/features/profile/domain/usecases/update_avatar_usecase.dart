// path: lib/features/profile/domain/usecases/update_avatar_usecase.dart
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../repositories/profile_repository.dart';

part 'update_avatar_usecase.g.dart';

@riverpod
UpdateAvatarUsecase updateAvatarUsecase(Ref ref) =>
    UpdateAvatarUsecase(ref.watch(profileRepositoryProvider));

class UpdateAvatarUsecase {
  final ProfileRepository _repo;

  const UpdateAvatarUsecase(this._repo);

  Future<Result<String>> call(XFile file) => _repo.updateAvatar(file);
}
