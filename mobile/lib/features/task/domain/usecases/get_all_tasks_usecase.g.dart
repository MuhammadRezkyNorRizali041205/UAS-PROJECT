// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_tasks_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAllTasksUsecase)
final getAllTasksUsecaseProvider = GetAllTasksUsecaseProvider._();

final class GetAllTasksUsecaseProvider extends $FunctionalProvider<
    GetAllTasksUsecase,
    GetAllTasksUsecase,
    GetAllTasksUsecase> with $Provider<GetAllTasksUsecase> {
  GetAllTasksUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getAllTasksUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getAllTasksUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetAllTasksUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllTasksUsecase create(Ref ref) {
    return getAllTasksUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllTasksUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllTasksUsecase>(value),
    );
  }
}

String _$getAllTasksUsecaseHash() =>
    r'787c553e25020fabbf8ef1328bcafaf7e569aa25';
