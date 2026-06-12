// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsRemoteDatasource)
final analyticsRemoteDatasourceProvider = AnalyticsRemoteDatasourceProvider._();

final class AnalyticsRemoteDatasourceProvider extends $FunctionalProvider<
    AnalyticsRemoteDatasource,
    AnalyticsRemoteDatasource,
    AnalyticsRemoteDatasource> with $Provider<AnalyticsRemoteDatasource> {
  AnalyticsRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsRemoteDatasource create(Ref ref) {
    return analyticsRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsRemoteDatasource>(value),
    );
  }
}

String _$analyticsRemoteDatasourceHash() =>
    r'797fc3eb94dea2a09a02c2ab433759660ef954c4';
