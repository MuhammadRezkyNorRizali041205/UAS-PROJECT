// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer_attendance_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lecturerAttendanceSessionsList)
final lecturerAttendanceSessionsListProvider =
    LecturerAttendanceSessionsListFamily._();

final class LecturerAttendanceSessionsListProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  LecturerAttendanceSessionsListProvider._(
      {required LecturerAttendanceSessionsListFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'lecturerAttendanceSessionsListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lecturerAttendanceSessionsListHash();

  @override
  String toString() {
    return r'lecturerAttendanceSessionsListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return lecturerAttendanceSessionsList(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LecturerAttendanceSessionsListProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lecturerAttendanceSessionsListHash() =>
    r'17da68782ad1c0f7cd68ef8fd69f887deabdecfa';

final class LecturerAttendanceSessionsListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, String> {
  LecturerAttendanceSessionsListFamily._()
      : super(
          retry: null,
          name: r'lecturerAttendanceSessionsListProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  LecturerAttendanceSessionsListProvider call(
    String classId,
  ) =>
      LecturerAttendanceSessionsListProvider._(argument: classId, from: this);

  @override
  String toString() => r'lecturerAttendanceSessionsListProvider';
}
