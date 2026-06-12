// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_dashboard_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getDashboardUsecase)
final getDashboardUsecaseProvider = GetDashboardUsecaseProvider._();

final class GetDashboardUsecaseProvider extends $FunctionalProvider<
    GetDashboardUsecase,
    GetDashboardUsecase,
    GetDashboardUsecase> with $Provider<GetDashboardUsecase> {
  GetDashboardUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getDashboardUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getDashboardUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetDashboardUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetDashboardUsecase create(Ref ref) {
    return getDashboardUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDashboardUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDashboardUsecase>(value),
    );
  }
}

String _$getDashboardUsecaseHash() =>
    r'a5a74562c1299da67fb735c8b48265829cff077c';
