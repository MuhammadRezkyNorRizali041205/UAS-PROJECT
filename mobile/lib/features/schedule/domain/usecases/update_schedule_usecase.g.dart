// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_schedule_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateScheduleUsecase)
final updateScheduleUsecaseProvider = UpdateScheduleUsecaseProvider._();

final class UpdateScheduleUsecaseProvider extends $FunctionalProvider<
    UpdateScheduleUsecase,
    UpdateScheduleUsecase,
    UpdateScheduleUsecase> with $Provider<UpdateScheduleUsecase> {
  UpdateScheduleUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateScheduleUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateScheduleUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateScheduleUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateScheduleUsecase create(Ref ref) {
    return updateScheduleUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateScheduleUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateScheduleUsecase>(value),
    );
  }
}

String _$updateScheduleUsecaseHash() =>
    r'1ed9cb31c45227e01f8162328697ad5b8fd21a68';
