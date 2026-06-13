// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer_class_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lecturerClassDetail)
final lecturerClassDetailProvider = LecturerClassDetailFamily._();

final class LecturerClassDetailProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  LecturerClassDetailProvider._(
      {required LecturerClassDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'lecturerClassDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lecturerClassDetailHash();

  @override
  String toString() {
    return r'lecturerClassDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return lecturerClassDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LecturerClassDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lecturerClassDetailHash() =>
    r'47ce9f803fbcac2378e61783dba0387625b4a620';

final class LecturerClassDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  LecturerClassDetailFamily._()
      : super(
          retry: null,
          name: r'lecturerClassDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  LecturerClassDetailProvider call(
    String classId,
  ) =>
      LecturerClassDetailProvider._(argument: classId, from: this);

  @override
  String toString() => r'lecturerClassDetailProvider';
}

@ProviderFor(lecturerClassTasks)
final lecturerClassTasksProvider = LecturerClassTasksFamily._();

final class LecturerClassTasksProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  LecturerClassTasksProvider._(
      {required LecturerClassTasksFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'lecturerClassTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lecturerClassTasksHash();

  @override
  String toString() {
    return r'lecturerClassTasksProvider'
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
    return lecturerClassTasks(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LecturerClassTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lecturerClassTasksHash() =>
    r'faf80c38d166190a0e1a8a11d19a1d63b1ed3389';

final class LecturerClassTasksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, String> {
  LecturerClassTasksFamily._()
      : super(
          retry: null,
          name: r'lecturerClassTasksProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  LecturerClassTasksProvider call(
    String classId,
  ) =>
      LecturerClassTasksProvider._(argument: classId, from: this);

  @override
  String toString() => r'lecturerClassTasksProvider';
}
