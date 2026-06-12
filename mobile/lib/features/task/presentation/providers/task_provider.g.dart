// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskList)
final taskListProvider = TaskListProvider._();

final class TaskListProvider
    extends $AsyncNotifierProvider<TaskList, List<TaskEntity>> {
  TaskListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskListHash();

  @$internal
  @override
  TaskList create() => TaskList();
}

String _$taskListHash() => r'c770a87c6b0aa4e152608eba5a3392d371385b55';

abstract class _$TaskList extends $AsyncNotifier<List<TaskEntity>> {
  FutureOr<List<TaskEntity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TaskEntity>>, List<TaskEntity>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TaskEntity>>, List<TaskEntity>>,
        AsyncValue<List<TaskEntity>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(upcomingTasks)
final upcomingTasksProvider = UpcomingTasksProvider._();

final class UpcomingTasksProvider extends $FunctionalProvider<
        AsyncValue<List<TaskEntity>>,
        List<TaskEntity>,
        FutureOr<List<TaskEntity>>>
    with $FutureModifier<List<TaskEntity>>, $FutureProvider<List<TaskEntity>> {
  UpcomingTasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'upcomingTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$upcomingTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskEntity>> create(Ref ref) {
    return upcomingTasks(ref);
  }
}

String _$upcomingTasksHash() => r'6eaffcb95f9ee0d0545ef51408713ec7d1a212ef';

@ProviderFor(overdueTasks)
final overdueTasksProvider = OverdueTasksProvider._();

final class OverdueTasksProvider extends $FunctionalProvider<
        AsyncValue<List<TaskEntity>>,
        List<TaskEntity>,
        FutureOr<List<TaskEntity>>>
    with $FutureModifier<List<TaskEntity>>, $FutureProvider<List<TaskEntity>> {
  OverdueTasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'overdueTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$overdueTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskEntity>> create(Ref ref) {
    return overdueTasks(ref);
  }
}

String _$overdueTasksHash() => r'7fbd290ab0c8d10fb77175a1a09c47310c417deb';

@ProviderFor(taskById)
final taskByIdProvider = TaskByIdFamily._();

final class TaskByIdProvider extends $FunctionalProvider<AsyncValue<TaskEntity>,
        TaskEntity, FutureOr<TaskEntity>>
    with $FutureModifier<TaskEntity>, $FutureProvider<TaskEntity> {
  TaskByIdProvider._(
      {required TaskByIdFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'taskByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskByIdHash();

  @override
  String toString() {
    return r'taskByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TaskEntity> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TaskEntity> create(Ref ref) {
    final argument = this.argument as int;
    return taskById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskByIdHash() => r'71739269c2bda953b955b2bd2af8726d6ead8aa0';

final class TaskByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TaskEntity>, int> {
  TaskByIdFamily._()
      : super(
          retry: null,
          name: r'taskByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  TaskByIdProvider call(
    int id,
  ) =>
      TaskByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'taskByIdProvider';
}
