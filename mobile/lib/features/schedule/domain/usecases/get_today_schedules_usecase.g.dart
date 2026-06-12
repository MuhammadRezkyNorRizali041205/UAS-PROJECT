// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_today_schedules_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getTodaySchedulesUsecase)
final getTodaySchedulesUsecaseProvider = GetTodaySchedulesUsecaseProvider._();

final class GetTodaySchedulesUsecaseProvider extends $FunctionalProvider<
    GetTodaySchedulesUsecase,
    GetTodaySchedulesUsecase,
    GetTodaySchedulesUsecase> with $Provider<GetTodaySchedulesUsecase> {
  GetTodaySchedulesUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getTodaySchedulesUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getTodaySchedulesUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetTodaySchedulesUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetTodaySchedulesUsecase create(Ref ref) {
    return getTodaySchedulesUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetTodaySchedulesUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetTodaySchedulesUsecase>(value),
    );
  }
}

String _$getTodaySchedulesUsecaseHash() =>
    r'8b5db4d4e309b10fdb7e99abe729b671b7d4696f';
