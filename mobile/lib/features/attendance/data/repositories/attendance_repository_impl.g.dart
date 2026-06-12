// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attendanceRepository)
final attendanceRepositoryProvider = AttendanceRepositoryProvider._();

final class AttendanceRepositoryProvider extends $FunctionalProvider<
    AttendanceRepository,
    AttendanceRepository,
    AttendanceRepository> with $Provider<AttendanceRepository> {
  AttendanceRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'attendanceRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$attendanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttendanceRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AttendanceRepository create(Ref ref) {
    return attendanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceRepository>(value),
    );
  }
}

String _$attendanceRepositoryHash() =>
    r'a1833efd34cef91578b056637bc82952ef210cc2';
