// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalyticsPeriod)
final analyticsPeriodProvider = AnalyticsPeriodProvider._();

final class AnalyticsPeriodProvider
    extends $NotifierProvider<AnalyticsPeriod, String> {
  AnalyticsPeriodProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsPeriodProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsPeriodHash();

  @$internal
  @override
  AnalyticsPeriod create() => AnalyticsPeriod();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$analyticsPeriodHash() => r'6c7d32f66097e7a46f5daa46703c1c238967d161';

abstract class _$AnalyticsPeriod extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(analyticsDashboard)
final analyticsDashboardProvider = AnalyticsDashboardProvider._();

final class AnalyticsDashboardProvider extends $FunctionalProvider<
        AsyncValue<DashboardAnalyticsEntity>,
        DashboardAnalyticsEntity,
        FutureOr<DashboardAnalyticsEntity>>
    with
        $FutureModifier<DashboardAnalyticsEntity>,
        $FutureProvider<DashboardAnalyticsEntity> {
  AnalyticsDashboardProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsDashboardProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsDashboardHash();

  @$internal
  @override
  $FutureProviderElement<DashboardAnalyticsEntity> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardAnalyticsEntity> create(Ref ref) {
    return analyticsDashboard(ref);
  }
}

String _$analyticsDashboardHash() =>
    r'33ce098d5286bf643242b28f0c13133b3b18465e';

@ProviderFor(analyticsHeatmap)
final analyticsHeatmapProvider = AnalyticsHeatmapProvider._();

final class AnalyticsHeatmapProvider extends $FunctionalProvider<
        AsyncValue<List<HeatmapDayEntity>>,
        List<HeatmapDayEntity>,
        FutureOr<List<HeatmapDayEntity>>>
    with
        $FutureModifier<List<HeatmapDayEntity>>,
        $FutureProvider<List<HeatmapDayEntity>> {
  AnalyticsHeatmapProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsHeatmapProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsHeatmapHash();

  @$internal
  @override
  $FutureProviderElement<List<HeatmapDayEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<HeatmapDayEntity>> create(Ref ref) {
    return analyticsHeatmap(ref);
  }
}

String _$analyticsHeatmapHash() => r'7875b48851c6c5ff11d64fcadf85fc72afc24274';

@ProviderFor(analyticsSummary)
final analyticsSummaryProvider = AnalyticsSummaryProvider._();

final class AnalyticsSummaryProvider extends $FunctionalProvider<
        AsyncValue<SummaryAnalyticsEntity>,
        SummaryAnalyticsEntity,
        FutureOr<SummaryAnalyticsEntity>>
    with
        $FutureModifier<SummaryAnalyticsEntity>,
        $FutureProvider<SummaryAnalyticsEntity> {
  AnalyticsSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<SummaryAnalyticsEntity> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SummaryAnalyticsEntity> create(Ref ref) {
    return analyticsSummary(ref);
  }
}

String _$analyticsSummaryHash() => r'c2a23b17b08ac18873e6929e6bebb279e35dee14';
