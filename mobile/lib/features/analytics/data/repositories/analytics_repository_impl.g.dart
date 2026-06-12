// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsRepository)
final analyticsRepositoryProvider = AnalyticsRepositoryProvider._();

final class AnalyticsRepositoryProvider extends $FunctionalProvider<
    AnalyticsRepositoryImpl,
    AnalyticsRepositoryImpl,
    AnalyticsRepositoryImpl> with $Provider<AnalyticsRepositoryImpl> {
  AnalyticsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnalyticsRepositoryImpl> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsRepositoryImpl create(Ref ref) {
    return analyticsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsRepositoryImpl>(value),
    );
  }
}

String _$analyticsRepositoryHash() =>
    r'8e37d6e610386d8cb235cd3a9c87180bf5c36f25';
