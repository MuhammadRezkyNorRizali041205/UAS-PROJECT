// path: lib/features/profile/data/datasources/profile_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

part 'profile_remote_datasource.g.dart';

@riverpod
ProfileRemoteDatasource profileRemoteDatasource(Ref ref) =>
    ProfileRemoteDatasource(ref.watch(dioClientProvider));

class ProfileRemoteDatasource {
  final DioClient _client;

  const ProfileRemoteDatasource(this._client);

  Future<UserProfileModel> getProfile() async {
    final res = await _client.get<Map<String, dynamic>>(ApiEndpoints.profile);
    final data = res['data'] as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    final res = await _client.put<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: data,
    );
    final body = res['data'] as Map<String, dynamic>;
    return UserProfileModel.fromJson(body);
  }

  Future<String> updateAvatar(XFile file) async {
    final bytes = await file.readAsBytes();
    final multipart = MultipartFile.fromBytes(
      bytes,
      filename: file.name,
    );

    final formData = FormData.fromMap({'avatar': multipart});

    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.profileAvatar,
      data: formData,
    );

    final data = res['data'] as Map<String, dynamic>;
    return data['avatar_url'] as String? ?? '';
  }

  Future<void> updateNotificationPrefs(Map<String, bool> prefs) async {
    await _client.patch<void>(
      ApiEndpoints.profileNotifications,
      data: prefs,
    );
  }
}
