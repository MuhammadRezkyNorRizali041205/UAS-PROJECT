// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_schedule_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(createScheduleUsecase)
final createScheduleUsecaseProvider = CreateScheduleUsecaseProvider._();

final class CreateScheduleUsecaseProvider extends $FunctionalProvider<
    CreateScheduleUsecase,
    CreateScheduleUsecase,
    CreateScheduleUsecase> with $Provider<CreateScheduleUsecase> {
  CreateScheduleUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createScheduleUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createScheduleUsecaseHash();

  @$internal
  @override
  $ProviderElement<CreateScheduleUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateScheduleUsecase create(Ref ref) {
    return createScheduleUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateScheduleUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateScheduleUsecase>(value),
    );
  }
}

String _$createScheduleUsecaseHash() =>
    r'8384860cdb21e709a04be16f0aed0dfbaf7bd052';
