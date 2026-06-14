// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer_task_submissions_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskSubmissions)
final taskSubmissionsProvider = TaskSubmissionsFamily._();

final class TaskSubmissionsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  TaskSubmissionsProvider._(
      {required TaskSubmissionsFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'taskSubmissionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskSubmissionsHash();

  @override
  String toString() {
    return r'taskSubmissionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return taskSubmissions(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskSubmissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskSubmissionsHash() => r'208d6763c28a660ba7b6ca3d1efd1c7db1add297';

final class TaskSubmissionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<Map<String, dynamic>>,
            (
              String,
              String,
            )> {
  TaskSubmissionsFamily._()
      : super(
          retry: null,
          name: r'taskSubmissionsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  TaskSubmissionsProvider call(
    String taskId,
    String filter,
  ) =>
      TaskSubmissionsProvider._(argument: (
        taskId,
        filter,
      ), from: this);

  @override
  String toString() => r'taskSubmissionsProvider';
}
