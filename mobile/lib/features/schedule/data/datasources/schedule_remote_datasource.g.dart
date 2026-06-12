// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scheduleRemoteDatasource)
final scheduleRemoteDatasourceProvider = ScheduleRemoteDatasourceProvider._();

final class ScheduleRemoteDatasourceProvider extends $FunctionalProvider<
    ScheduleRemoteDatasource,
    ScheduleRemoteDatasource,
    ScheduleRemoteDatasource> with $Provider<ScheduleRemoteDatasource> {
  ScheduleRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<ScheduleRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScheduleRemoteDatasource create(Ref ref) {
    return scheduleRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleRemoteDatasource>(value),
    );
  }
}

String _$scheduleRemoteDatasourceHash() =>
    r'129b77d1e4d417308e7a64c774abd0ae6e9ba30c';
