// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleList)
final scheduleListProvider = ScheduleListProvider._();

final class ScheduleListProvider
    extends $AsyncNotifierProvider<ScheduleList, List<ScheduleEntity>> {
  ScheduleListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleListHash();

  @$internal
  @override
  ScheduleList create() => ScheduleList();
}

String _$scheduleListHash() => r'87158f816de05f014a4719f95c4564d3ca6ee506';

abstract class _$ScheduleList extends $AsyncNotifier<List<ScheduleEntity>> {
  FutureOr<List<ScheduleEntity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<ScheduleEntity>>, List<ScheduleEntity>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ScheduleEntity>>, List<ScheduleEntity>>,
        AsyncValue<List<ScheduleEntity>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(todaySchedules)
final todaySchedulesProvider = TodaySchedulesProvider._();

final class TodaySchedulesProvider extends $FunctionalProvider<
        AsyncValue<List<ScheduleEntity>>,
        List<ScheduleEntity>,
        FutureOr<List<ScheduleEntity>>>
    with
        $FutureModifier<List<ScheduleEntity>>,
        $FutureProvider<List<ScheduleEntity>> {
  TodaySchedulesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todaySchedulesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaySchedulesHash();

  @$internal
  @override
  $FutureProviderElement<List<ScheduleEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScheduleEntity>> create(Ref ref) {
    return todaySchedules(ref);
  }
}

String _$todaySchedulesHash() => r'3764fb1b5ab566e8f165e144f29241b437a5c21b';

@ProviderFor(weekSchedules)
final weekSchedulesProvider = WeekSchedulesProvider._();

final class WeekSchedulesProvider extends $FunctionalProvider<
        AsyncValue<List<ScheduleEntity>>,
        List<ScheduleEntity>,
        FutureOr<List<ScheduleEntity>>>
    with
        $FutureModifier<List<ScheduleEntity>>,
        $FutureProvider<List<ScheduleEntity>> {
  WeekSchedulesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weekSchedulesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weekSchedulesHash();

  @$internal
  @override
  $FutureProviderElement<List<ScheduleEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScheduleEntity>> create(Ref ref) {
    return weekSchedules(ref);
  }
}

String _$weekSchedulesHash() => r'91761941de2f42c025a435624e46b0eb21e162b8';

@ProviderFor(scheduleById)
final scheduleByIdProvider = ScheduleByIdFamily._();

final class ScheduleByIdProvider extends $FunctionalProvider<
        AsyncValue<ScheduleEntity>, ScheduleEntity, FutureOr<ScheduleEntity>>
    with $FutureModifier<ScheduleEntity>, $FutureProvider<ScheduleEntity> {
  ScheduleByIdProvider._(
      {required ScheduleByIdFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'scheduleByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleByIdHash();

  @override
  String toString() {
    return r'scheduleByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ScheduleEntity> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ScheduleEntity> create(Ref ref) {
    final argument = this.argument as int;
    return scheduleById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduleByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scheduleByIdHash() => r'e0139f72704154909213e97a9e3cb326449f2a57';

final class ScheduleByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ScheduleEntity>, int> {
  ScheduleByIdFamily._()
      : super(
          retry: null,
          name: r'scheduleByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ScheduleByIdProvider call(
    int id,
  ) =>
      ScheduleByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'scheduleByIdProvider';
}
