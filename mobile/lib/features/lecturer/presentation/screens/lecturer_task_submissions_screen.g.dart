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
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
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
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
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

String _$taskSubmissionsHash() => r'f9968a16387ee624b90ce1438d5a3250b3f366b2';

final class TaskSubmissionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<dynamic>>,
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
