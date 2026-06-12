import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'login_usecase.g.dart';

@riverpod
LoginUsecase loginUsecase(Ref ref) =>
    LoginUsecase(ref.watch(authRepositoryProvider));

class LoginUsecase {
  final AuthRepository _repository;
  const LoginUsecase(this._repository);

  Future<Result<({UserEntity user, String token})>> call({
    required String email,
    required String password,
    String? fcmToken,
  }) => _repository.login(email: email, password: password, fcmToken: fcmToken);
}
