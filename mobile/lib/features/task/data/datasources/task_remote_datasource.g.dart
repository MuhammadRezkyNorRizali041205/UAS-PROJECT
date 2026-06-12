// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskRemoteDatasource)
final taskRemoteDatasourceProvider = TaskRemoteDatasourceProvider._();

final class TaskRemoteDatasourceProvider extends $FunctionalProvider<
    TaskRemoteDatasource,
    TaskRemoteDatasource,
    TaskRemoteDatasource> with $Provider<TaskRemoteDatasource> {
  TaskRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<TaskRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRemoteDatasource create(Ref ref) {
    return taskRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRemoteDatasource>(value),
    );
  }
}

String _$taskRemoteDatasourceHash() =>
    r'd6c782f7a7948f898a51c99fce4acd914f9c9cee';
