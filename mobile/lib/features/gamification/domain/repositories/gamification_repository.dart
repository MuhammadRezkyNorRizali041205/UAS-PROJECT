import '../../../../core/errors/failures.dart';
import '../../data/models/gamification_model.dart';

abstract class GamificationRepository {
  Future<Result<GamificationProfileModel>> getProfile();
  Future<Result<List<QuestModel>>> getQuests();
  Future<Result<AchievementListModel>> getAchievements();
  Future<Result<LeaderboardModel>> getLeaderboard({String scope = 'campus'});
  Future<Result<List<PointHistoryModel>>> getPointHistory({int page = 1});
}
