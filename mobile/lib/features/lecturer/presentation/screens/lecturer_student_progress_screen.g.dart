// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer_student_progress_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentProgress)
final studentProgressProvider = StudentProgressFamily._();

final class StudentProgressProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  StudentProgressProvider._(
      {required StudentProgressFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'studentProgressProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studentProgressHash();

  @override
  String toString() {
    return r'studentProgressProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return studentProgress(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudentProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentProgressHash() => r'c2bc4b0d21868b1c58a95655e11507f8aadda053';

final class StudentProgressFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<Map<String, dynamic>>,
            (
              String,
              String,
            )> {
  StudentProgressFamily._()
      : super(
          retry: null,
          name: r'studentProgressProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  StudentProgressProvider call(
    String classId,
    String studentId,
  ) =>
      StudentProgressProvider._(argument: (
        classId,
        studentId,
      ), from: this);

  @override
  String toString() => r'studentProgressProvider';
}
