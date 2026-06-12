// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_week_schedules_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getWeekSchedulesUsecase)
final getWeekSchedulesUsecaseProvider = GetWeekSchedulesUsecaseProvider._();

final class GetWeekSchedulesUsecaseProvider extends $FunctionalProvider<
    GetWeekSchedulesUsecase,
    GetWeekSchedulesUsecase,
    GetWeekSchedulesUsecase> with $Provider<GetWeekSchedulesUsecase> {
  GetWeekSchedulesUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getWeekSchedulesUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getWeekSchedulesUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetWeekSchedulesUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetWeekSchedulesUsecase create(Ref ref) {
    return getWeekSchedulesUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWeekSchedulesUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWeekSchedulesUsecase>(value),
    );
  }
}

String _$getWeekSchedulesUsecaseHash() =>
    r'c9d10d2c2f8ceedf1ef44e87131285305dcb12b7';
