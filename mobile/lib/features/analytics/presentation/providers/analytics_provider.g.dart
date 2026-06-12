// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$analyticsSummaryHash() => r'6c8d7576f8c5f537c66d5bd2dbc1e075164338c8';
