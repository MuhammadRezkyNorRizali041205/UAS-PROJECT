// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateTaskUsecase)
final updateTaskUsecaseProvider = UpdateTaskUsecaseProvider._();

final class UpdateTaskUsecaseProvider extends $FunctionalProvider<
    UpdateTaskUsecase,
    UpdateTaskUsecase,
    UpdateTaskUsecase> with $Provider<UpdateTaskUsecase> {
  UpdateTaskUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateTaskUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateTaskUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateTaskUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateTaskUsecase create(Ref ref) {
    return updateTaskUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateTaskUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateTaskUsecase>(value),
    );
  }
}

String _$updateTaskUsecaseHash() => r'f199a02dbaad3edacd89e26bb823d843aea38139';
