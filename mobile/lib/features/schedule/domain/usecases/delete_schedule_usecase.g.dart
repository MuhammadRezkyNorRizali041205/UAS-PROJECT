// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_schedule_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deleteScheduleUsecase)
final deleteScheduleUsecaseProvider = DeleteScheduleUsecaseProvider._();

final class DeleteScheduleUsecaseProvider extends $FunctionalProvider<
    DeleteScheduleUsecase,
    DeleteScheduleUsecase,
    DeleteScheduleUsecase> with $Provider<DeleteScheduleUsecase> {
  DeleteScheduleUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteScheduleUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteScheduleUsecaseHash();

  @$internal
  @override
  $ProviderElement<DeleteScheduleUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteScheduleUsecase create(Ref ref) {
    return deleteScheduleUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteScheduleUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteScheduleUsecase>(value),
    );
  }
}

String _$deleteScheduleUsecaseHash() =>
    r'4d63ab82e95760f3d69ac3c07af39124041d21f2';
