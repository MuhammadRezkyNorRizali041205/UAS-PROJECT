import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'register_usecase.g.dart';

@riverpod
RegisterUsecase registerUsecase(Ref ref) =>
    RegisterUsecase(ref.watch(authRepositoryProvider));

class RegisterUsecase {
  final AuthRepository _repository;
  const RegisterUsecase(this._repository);

  Future<Result<({UserEntity user, String token})>> call({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) =>
      _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
}
