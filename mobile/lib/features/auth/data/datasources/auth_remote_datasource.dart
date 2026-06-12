import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasource(ref.watch(dioClientProvider));

class AuthRemoteDatasource {
  final DioClient _client;
  const AuthRemoteDatasource(this._client);

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
    );
    final data = res['data'] as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password, 'role': role},
    );
    final data = res['data'] as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  Future<void> logout() async {
    await _client.post<void>(ApiEndpoints.logout);
  }

  Future<UserModel> getMe() async {
    final res = await _client.get<Map<String, dynamic>>(ApiEndpoints.me);
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) async {
    await _client.post<void>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _client.post<void>(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}
