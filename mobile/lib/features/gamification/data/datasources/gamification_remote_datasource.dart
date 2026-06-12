import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/gamification_model.dart';

part 'gamification_remote_datasource.g.dart';

@riverpod
GamificationRemoteDatasource gamificationRemoteDatasource(Ref ref) =>
    GamificationRemoteDatasource(ref.watch(dioClientProvider));

class GamificationRemoteDatasource {
  const GamificationRemoteDatasource(this._client);

  final DioClient _client;

  Future<GamificationProfileModel> getProfile() async {
    final res = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.gamificationProfile);
    return GamificationProfileModel.fromJson(
        res['data'] as Map<String, dynamic>);
  }

  Future<List<QuestModel>> getQuests() async {
    final res = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.gamificationQuests);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => QuestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AchievementListModel> getAchievements() async {
    final res = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.gamificationAchievements);
    return AchievementListModel.fromJson(
        res['data'] as Map<String, dynamic>);
  }

  Future<LeaderboardModel> getLeaderboard({String scope = 'campus'}) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.leaderboard,
      queryParameters: {'scope': scope},
    );
    return LeaderboardModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<List<PointHistoryModel>> getPointHistory({int page = 1}) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.gamificationHistory,
      queryParameters: {'page': page, 'per_page': 20},
    );
    final list = (res['data']['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => PointHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
