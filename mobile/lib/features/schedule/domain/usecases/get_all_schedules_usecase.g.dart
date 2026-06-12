// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_schedules_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAllSchedulesUsecase)
final getAllSchedulesUsecaseProvider = GetAllSchedulesUsecaseProvider._();

final class GetAllSchedulesUsecaseProvider extends $FunctionalProvider<
    GetAllSchedulesUsecase,
    GetAllSchedulesUsecase,
    GetAllSchedulesUsecase> with $Provider<GetAllSchedulesUsecase> {
  GetAllSchedulesUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getAllSchedulesUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getAllSchedulesUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetAllSchedulesUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllSchedulesUsecase create(Ref ref) {
    return getAllSchedulesUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllSchedulesUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllSchedulesUsecase>(value),
    );
  }
}

String _$getAllSchedulesUsecaseHash() =>
    r'7425d7534119884ec76e46b0fd2dd5f27c727a30';
