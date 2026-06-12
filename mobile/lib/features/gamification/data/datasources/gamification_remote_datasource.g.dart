// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gamificationRemoteDatasource)
final gamificationRemoteDatasourceProvider =
    GamificationRemoteDatasourceProvider._();

final class GamificationRemoteDatasourceProvider extends $FunctionalProvider<
    GamificationRemoteDatasource,
    GamificationRemoteDatasource,
    GamificationRemoteDatasource> with $Provider<GamificationRemoteDatasource> {
  GamificationRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gamificationRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gamificationRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<GamificationRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GamificationRemoteDatasource create(Ref ref) {
    return gamificationRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GamificationRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GamificationRemoteDatasource>(value),
    );
  }
}

String _$gamificationRemoteDatasourceHash() =>
    r'43e4dcb12a991b4d06acc97895b157e76fcc866b';
