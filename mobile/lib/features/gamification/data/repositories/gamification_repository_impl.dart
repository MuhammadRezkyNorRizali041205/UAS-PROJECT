import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_datasource.dart';
import '../models/gamification_model.dart';

part 'gamification_repository_impl.g.dart';

@riverpod
GamificationRepository gamificationRepository(Ref ref) =>
    GamificationRepositoryImpl(
        ref.watch(gamificationRemoteDatasourceProvider));

class GamificationRepositoryImpl implements GamificationRepository {
  const GamificationRepositoryImpl(this._datasource);

  final GamificationRemoteDatasource _datasource;

  @override
  Future<Result<GamificationProfileModel>> getProfile() =>
      _run(() => _datasource.getProfile());

  @override
  Future<Result<List<QuestModel>>> getQuests() =>
      _run(() => _datasource.getQuests());

  @override
  Future<Result<AchievementListModel>> getAchievements() =>
      _run(() => _datasource.getAchievements());

  @override
  Future<Result<LeaderboardModel>> getLeaderboard(
          {String scope = 'campus'}) =>
      _run(() => _datasource.getLeaderboard(scope: scope));

  @override
  Future<Result<List<PointHistoryModel>>> getPointHistory({int page = 1}) =>
      _run(() => _datasource.getPointHistory(page: page));

  // ─── Helper ───────────────────────────────────────────────────────────────

  Future<Result<T>> _run<T>(Future<T> Function() call) async {
    try {
      return Success(await call());
    } on AuthException catch (e) {
      return Failure(e.message, exception: e);
    } on ServerException catch (e) {
      return Failure(e.message, exception: e);
    } on NetworkException catch (e) {
      return Failure(e.message, exception: e);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
