// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_status_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateTaskStatusUsecase)
final updateTaskStatusUsecaseProvider = UpdateTaskStatusUsecaseProvider._();

final class UpdateTaskStatusUsecaseProvider extends $FunctionalProvider<
    UpdateTaskStatusUsecase,
    UpdateTaskStatusUsecase,
    UpdateTaskStatusUsecase> with $Provider<UpdateTaskStatusUsecase> {
  UpdateTaskStatusUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateTaskStatusUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateTaskStatusUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateTaskStatusUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateTaskStatusUsecase create(Ref ref) {
    return updateTaskStatusUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateTaskStatusUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateTaskStatusUsecase>(value),
    );
  }
}

String _$updateTaskStatusUsecaseHash() =>
    r'15fd2d0cd437ae6cfb17c8fa7966ac6b49752c77';
