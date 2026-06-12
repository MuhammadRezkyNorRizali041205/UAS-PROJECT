// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_upcoming_tasks_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getUpcomingTasksUsecase)
final getUpcomingTasksUsecaseProvider = GetUpcomingTasksUsecaseProvider._();

final class GetUpcomingTasksUsecaseProvider extends $FunctionalProvider<
    GetUpcomingTasksUsecase,
    GetUpcomingTasksUsecase,
    GetUpcomingTasksUsecase> with $Provider<GetUpcomingTasksUsecase> {
  GetUpcomingTasksUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getUpcomingTasksUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getUpcomingTasksUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetUpcomingTasksUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetUpcomingTasksUsecase create(Ref ref) {
    return getUpcomingTasksUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetUpcomingTasksUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetUpcomingTasksUsecase>(value),
    );
  }
}

String _$getUpcomingTasksUsecaseHash() =>
    r'f3f682eef13f159b87ad34f97e04c1356394ff5f';
