// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gamificationRepository)
final gamificationRepositoryProvider = GamificationRepositoryProvider._();

final class GamificationRepositoryProvider extends $FunctionalProvider<
    GamificationRepository,
    GamificationRepository,
    GamificationRepository> with $Provider<GamificationRepository> {
  GamificationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gamificationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gamificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<GamificationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GamificationRepository create(Ref ref) {
    return gamificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GamificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GamificationRepository>(value),
    );
  }
}

String _$gamificationRepositoryHash() =>
    r'81bf4b5b08e4c02344a81cfb40772a0281bc279f';
