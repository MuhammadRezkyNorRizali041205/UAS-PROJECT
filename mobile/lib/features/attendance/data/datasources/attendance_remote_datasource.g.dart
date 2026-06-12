// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attendanceRemoteDatasource)
final attendanceRemoteDatasourceProvider =
    AttendanceRemoteDatasourceProvider._();

final class AttendanceRemoteDatasourceProvider extends $FunctionalProvider<
    AttendanceRemoteDatasource,
    AttendanceRemoteDatasource,
    AttendanceRemoteDatasource> with $Provider<AttendanceRemoteDatasource> {
  AttendanceRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'attendanceRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$attendanceRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<AttendanceRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AttendanceRemoteDatasource create(Ref ref) {
    return attendanceRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceRemoteDatasource>(value),
    );
  }
}

String _$attendanceRemoteDatasourceHash() =>
    r'c3e84efd55a0d5f545529147ab4730e345df2f7d';
