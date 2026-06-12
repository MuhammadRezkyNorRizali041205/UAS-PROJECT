// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(createTaskUsecase)
final createTaskUsecaseProvider = CreateTaskUsecaseProvider._();

final class CreateTaskUsecaseProvider extends $FunctionalProvider<
    CreateTaskUsecase,
    CreateTaskUsecase,
    CreateTaskUsecase> with $Provider<CreateTaskUsecase> {
  CreateTaskUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createTaskUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createTaskUsecaseHash();

  @$internal
  @override
  $ProviderElement<CreateTaskUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateTaskUsecase create(Ref ref) {
    return createTaskUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateTaskUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateTaskUsecase>(value),
    );
  }
}

String _$createTaskUsecaseHash() => r'0b40e8936d1033d9f51d84fb6675479bbb9ff0bb';
