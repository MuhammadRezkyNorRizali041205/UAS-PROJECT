import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<({UserEntity user, String token})>> login({
    required String email,
    required String password,
    String? fcmToken,
  });

  Future<Result<({UserEntity user, String token})>> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  });

  Future<Result<void>> logout();

  Future<Result<UserEntity>> getMe();

  Future<Result<void>> forgotPassword(String email);

  Future<Result<void>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  /// Returns saved token or null.
  Future<String?> getSavedToken();

  /// Clears local auth data.
  Future<void> clearSession();
}
