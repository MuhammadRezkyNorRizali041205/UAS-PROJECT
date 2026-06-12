// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_overdue_tasks_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getOverdueTasksUsecase)
final getOverdueTasksUsecaseProvider = GetOverdueTasksUsecaseProvider._();

final class GetOverdueTasksUsecaseProvider extends $FunctionalProvider<
    GetOverdueTasksUsecase,
    GetOverdueTasksUsecase,
    GetOverdueTasksUsecase> with $Provider<GetOverdueTasksUsecase> {
  GetOverdueTasksUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getOverdueTasksUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getOverdueTasksUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetOverdueTasksUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetOverdueTasksUsecase create(Ref ref) {
    return getOverdueTasksUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetOverdueTasksUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetOverdueTasksUsecase>(value),
    );
  }
}

String _$getOverdueTasksUsecaseHash() =>
    r'765f2a4176e0262e57f9600d819ab75d30b3a1d5';
