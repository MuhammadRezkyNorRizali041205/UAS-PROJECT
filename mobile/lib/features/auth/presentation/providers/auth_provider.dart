// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_provider.g.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  const AuthError(this.message, {this.fieldErrors});
}

// ─── Auth Notifier ────────────────────────────────────────────────────────────
//
// Class is named `Auth` so build_runner generates `authProvider`,
// matching all screen references (ref.watch(authProvider)).
//
@riverpod
class Auth extends _$Auth {
  // Shared storage with consistent WebOptions so all parts of the app
  // (splash, dio interceptor, repository) read from the same location.
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'smart_campus_db',
      publicKey: 'smart_campus_key',
    ),
  );

  @override
  AuthState build() {
    _checkSession();
    return const AuthInitial();
  }

  Future<void> _checkSession() async {
    try {
      // Read token directly from storage (avoids repository layer overhead)
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null || token.isEmpty) {
        state = const AuthUnauthenticated();
        return;
      }

      // Token present — verify with server (timeout prevents web hang)
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.getMe().timeout(const Duration(seconds: 8));
      result.when(
        success: (user) => state = AuthAuthenticated(user),
        failure: (_, __) {
          // Token was rejected by server — clear it
          _storage.delete(key: AppConstants.tokenKey);
          _storage.delete(key: AppConstants.userKey);
          state = const AuthUnauthenticated();
        },
      );
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    state = const AuthLoading();

    final usecase = ref.read(loginUsecaseProvider);
    final result = await usecase(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );

    result.when(
      success: (data) => state = AuthAuthenticated(data.user),
      failure: (msg, exception) {
        final fieldErrors =
            exception is ValidationException ? exception.fieldErrors : null;
        state = AuthError(msg, fieldErrors: fieldErrors);
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    state = const AuthLoading();

    final usecase = ref.read(registerUsecaseProvider);
    final result = await usecase(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    result.when(
      success: (data) => state = AuthAuthenticated(data.user),
      failure: (msg, exception) {
        final fieldErrors =
            exception is ValidationException ? exception.fieldErrors : null;
        state = AuthError(msg, fieldErrors: fieldErrors);
      },
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AuthUnauthenticated();
  }

  Future<bool> forgotPassword(String email) async {
    final result = await ref.read(authRepositoryProvider).forgotPassword(email);
    return result.isSuccess;
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await ref.read(authRepositoryProvider).resetPassword(
          email: email,
          otp: otp,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
    return result.isSuccess;
  }
}
