// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gamificationProfile)
final gamificationProfileProvider = GamificationProfileProvider._();

final class GamificationProfileProvider extends $FunctionalProvider<
        AsyncValue<GamificationProfileModel>,
        GamificationProfileModel,
        FutureOr<GamificationProfileModel>>
    with
        $FutureModifier<GamificationProfileModel>,
        $FutureProvider<GamificationProfileModel> {
  GamificationProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gamificationProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gamificationProfileHash();

  @$internal
  @override
  $FutureProviderElement<GamificationProfileModel> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GamificationProfileModel> create(Ref ref) {
    return gamificationProfile(ref);
  }
}

String _$gamificationProfileHash() =>
    r'7475ee30fd62de29ad475abe3b28193f80f7505b';

@ProviderFor(dailyQuests)
final dailyQuestsProvider = DailyQuestsProvider._();

final class DailyQuestsProvider extends $FunctionalProvider<
        AsyncValue<List<QuestModel>>,
        List<QuestModel>,
        FutureOr<List<QuestModel>>>
    with $FutureModifier<List<QuestModel>>, $FutureProvider<List<QuestModel>> {
  DailyQuestsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dailyQuestsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailyQuestsHash();

  @$internal
  @override
  $FutureProviderElement<List<QuestModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuestModel>> create(Ref ref) {
    return dailyQuests(ref);
  }
}

String _$dailyQuestsHash() => r'd776147e06aec3976f3e68d9dabef15a0468772b';

@ProviderFor(achievements)
final achievementsProvider = AchievementsProvider._();

final class AchievementsProvider extends $FunctionalProvider<
        AsyncValue<AchievementListModel>,
        AchievementListModel,
        FutureOr<AchievementListModel>>
    with
        $FutureModifier<AchievementListModel>,
        $FutureProvider<AchievementListModel> {
  AchievementsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'achievementsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$achievementsHash();

  @$internal
  @override
  $FutureProviderElement<AchievementListModel> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AchievementListModel> create(Ref ref) {
    return achievements(ref);
  }
}

String _$achievementsHash() => r'9031a2989b0a79a29fc0e4434e39038263e35ecc';

@ProviderFor(LeaderboardNotifier)
final leaderboardProvider = LeaderboardNotifierProvider._();

final class LeaderboardNotifierProvider
    extends $AsyncNotifierProvider<LeaderboardNotifier, LeaderboardModel> {
  LeaderboardNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'leaderboardProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$leaderboardNotifierHash();

  @$internal
  @override
  LeaderboardNotifier create() => LeaderboardNotifier();
}

String _$leaderboardNotifierHash() =>
    r'638879eb2c802afaffccb2ce4ccb182d6d8d3067';

abstract class _$LeaderboardNotifier extends $AsyncNotifier<LeaderboardModel> {
  FutureOr<LeaderboardModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LeaderboardModel>, LeaderboardModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<LeaderboardModel>, LeaderboardModel>,
        AsyncValue<LeaderboardModel>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
