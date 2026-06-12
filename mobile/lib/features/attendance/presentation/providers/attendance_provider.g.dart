// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attendanceStats)
final attendanceStatsProvider = AttendanceStatsProvider._();

final class AttendanceStatsProvider extends $FunctionalProvider<
        AsyncValue<AttendanceStatsEntity>,
        AttendanceStatsEntity,
        FutureOr<AttendanceStatsEntity>>
    with
        $FutureModifier<AttendanceStatsEntity>,
        $FutureProvider<AttendanceStatsEntity> {
  AttendanceStatsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'attendanceStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$attendanceStatsHash();

  @$internal
  @override
  $FutureProviderElement<AttendanceStatsEntity> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AttendanceStatsEntity> create(Ref ref) {
    return attendanceStats(ref);
  }
}

String _$attendanceStatsHash() => r'e77081a3c20352b0a2fb5098553c83bfdcdd17ba';

@ProviderFor(attendanceHistory)
final attendanceHistoryProvider = AttendanceHistoryProvider._();

final class AttendanceHistoryProvider extends $FunctionalProvider<
        AsyncValue<List<AttendanceLogEntity>>,
        List<AttendanceLogEntity>,
        FutureOr<List<AttendanceLogEntity>>>
    with
        $FutureModifier<List<AttendanceLogEntity>>,
        $FutureProvider<List<AttendanceLogEntity>> {
  AttendanceHistoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'attendanceHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$attendanceHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<AttendanceLogEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<AttendanceLogEntity>> create(Ref ref) {
    return attendanceHistory(ref);
  }
}

String _$attendanceHistoryHash() => r'3e6f2e7586dab990dbe13ea861f85029d95b2256';

@ProviderFor(CreateSession)
final createSessionProvider = CreateSessionProvider._();

final class CreateSessionProvider extends $NotifierProvider<CreateSession,
    AsyncValue<AttendanceSessionEntity?>> {
  CreateSessionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createSessionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createSessionHash();

  @$internal
  @override
  CreateSession create() => CreateSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AttendanceSessionEntity?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<AttendanceSessionEntity?>>(value),
    );
  }
}

String _$createSessionHash() => r'ddd8239bb6e378f64c3bbbd3f100092276370ff5';

abstract class _$CreateSession
    extends $Notifier<AsyncValue<AttendanceSessionEntity?>> {
  AsyncValue<AttendanceSessionEntity?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AttendanceSessionEntity?>,
        AsyncValue<AttendanceSessionEntity?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AttendanceSessionEntity?>,
            AsyncValue<AttendanceSessionEntity?>>,
        AsyncValue<AttendanceSessionEntity?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ScanQr)
final scanQrProvider = ScanQrProvider._();

final class ScanQrProvider
    extends $NotifierProvider<ScanQr, AsyncValue<AttendanceLogEntity?>> {
  ScanQrProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scanQrProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scanQrHash();

  @$internal
  @override
  ScanQr create() => ScanQr();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AttendanceLogEntity?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<AttendanceLogEntity?>>(value),
    );
  }
}

String _$scanQrHash() => r'222ff08883ee8ed37294a0f4a61545c8d986bb6d';

abstract class _$ScanQr extends $Notifier<AsyncValue<AttendanceLogEntity?>> {
  AsyncValue<AttendanceLogEntity?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AttendanceLogEntity?>,
        AsyncValue<AttendanceLogEntity?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AttendanceLogEntity?>,
            AsyncValue<AttendanceLogEntity?>>,
        AsyncValue<AttendanceLogEntity?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
