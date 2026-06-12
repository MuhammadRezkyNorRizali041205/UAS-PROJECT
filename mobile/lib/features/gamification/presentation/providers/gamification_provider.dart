import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/gamification_model.dart';
import '../../data/repositories/gamification_repository_impl.dart';

part 'gamification_provider.g.dart';

// ─── Gamification Profile ─────────────────────────────────────────────────────

@riverpod
Future<GamificationProfileModel> gamificationProfile(Ref ref) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  final result = await repo.getProfile();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── Daily Quests ─────────────────────────────────────────────────────────────

@riverpod
Future<List<QuestModel>> dailyQuests(Ref ref) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  final result = await repo.getQuests();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── Achievements ─────────────────────────────────────────────────────────────

@riverpod
Future<AchievementListModel> achievements(Ref ref) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  final result = await repo.getAchievements();
  return result.when(
    success: (data) => data,
    failure: (msg, _) => throw Exception(msg),
  );
}

// ─── Leaderboard ─────────────────────────────────────────────────────────────

@riverpod
class LeaderboardNotifier extends _$LeaderboardNotifier {
  @override
  Future<LeaderboardModel> build() => _fetch('campus');

  String _currentScope = 'campus';
  String get currentScope => _currentScope;

  Future<void> changeScope(String scope) async {
    _currentScope = scope;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(scope));
  }

  Future<LeaderboardModel> _fetch(String scope) async {
    final repo = ref.read(gamificationRepositoryProvider);
    final result = await repo.getLeaderboard(scope: scope);
    return result.when(
      success: (data) => data,
      failure: (msg, _) => throw Exception(msg),
    );
  }
}
