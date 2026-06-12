// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardData)
final dashboardDataProvider = DashboardDataProvider._();

final class DashboardDataProvider extends $FunctionalProvider<
        AsyncValue<DashboardData>, DashboardData, FutureOr<DashboardData>>
    with $FutureModifier<DashboardData>, $FutureProvider<DashboardData> {
  DashboardDataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardDataProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardDataHash();

  @$internal
  @override
  $FutureProviderElement<DashboardData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardData> create(Ref ref) {
    return dashboardData(ref);
  }
}

String _$dashboardDataHash() => r'066ccca49a0b337fab7a51cf04fa3912cde6dee1';
