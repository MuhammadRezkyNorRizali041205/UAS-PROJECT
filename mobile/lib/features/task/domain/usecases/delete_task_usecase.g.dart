// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_task_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deleteTaskUsecase)
final deleteTaskUsecaseProvider = DeleteTaskUsecaseProvider._();

final class DeleteTaskUsecaseProvider extends $FunctionalProvider<
    DeleteTaskUsecase,
    DeleteTaskUsecase,
    DeleteTaskUsecase> with $Provider<DeleteTaskUsecase> {
  DeleteTaskUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteTaskUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteTaskUsecaseHash();

  @$internal
  @override
  $ProviderElement<DeleteTaskUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteTaskUsecase create(Ref ref) {
    return deleteTaskUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteTaskUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteTaskUsecase>(value),
    );
  }
}

String _$deleteTaskUsecaseHash() => r'480a01fbe7c726af12fbfbcea584b9053412e90a';
