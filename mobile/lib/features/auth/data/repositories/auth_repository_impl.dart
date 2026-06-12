import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      ref.watch(authRemoteDatasourceProvider),
      const FlutterSecureStorage(
        webOptions: WebOptions(
            dbName: 'smart_campus_db', publicKey: 'smart_campus_key'),
      ),
    );

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final FlutterSecureStorage _storage;

  const AuthRepositoryImpl(this._datasource, this._storage);

  @override
  Future<Result<({UserEntity user, String token})>> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final result = await _datasource.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );
      await _saveSession(result.user, result.token);
      return Success((user: result.user, token: result.token));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AuthException catch (e) {
      return Failure(e.message, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return const Failure('Terjadi kesalahan saat login.');
    }
  }

  @override
  Future<Result<({UserEntity user, String token})>> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    try {
      final result = await _datasource.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await _saveSession(result.user, result.token);
      return Success((user: result.user, token: result.token));
    } on ValidationException catch (e) {
      return Failure(e.allErrors, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return const Failure('Terjadi kesalahan saat registrasi.');
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _datasource.logout();
    } catch (_) {
      // Even if server call fails, clear local session
    }
    await clearSession();
    return const Success(null);
  }

  @override
  Future<Result<UserEntity>> getMe() async {
    try {
      final user = await _datasource.getMe();
      // Refresh stored user
      await _storage.write(
        key: AppConstants.userKey,
        value: jsonEncode(user.toJson()),
      );
      return Success(user);
    } on AuthException catch (e) {
      await clearSession();
      return Failure(e.message, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return const Failure('Gagal memuat data pengguna.');
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _datasource.forgotPassword(email);
      return const Success(null);
    } on ValidationException catch (e) {
      return Failure(e.message, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return const Failure('Gagal mengirim OTP.');
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _datasource.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Success(null);
    } on ValidationException catch (e) {
      return Failure(e.message, exception: e);
    } on AppException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return const Failure('Gagal mereset password.');
    }
  }

  @override
  Future<String?> getSavedToken() => _storage.read(key: AppConstants.tokenKey);

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: AppConstants.tokenKey),
      _storage.delete(key: AppConstants.userKey),
    ]);
  }

  Future<void> _saveSession(UserModel user, String token) async {
    await Future.wait([
      _storage.write(key: AppConstants.tokenKey, value: token),
      _storage.write(
        key: AppConstants.userKey,
        value: jsonEncode(user.toJson()),
      ),
    ]);
  }
}
