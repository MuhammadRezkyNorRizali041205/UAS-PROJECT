// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_task_submit_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentTaskSubmission)
final studentTaskSubmissionProvider = StudentTaskSubmissionFamily._();

final class StudentTaskSubmissionProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  StudentTaskSubmissionProvider._(
      {required StudentTaskSubmissionFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'studentTaskSubmissionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studentTaskSubmissionHash();

  @override
  String toString() {
    return r'studentTaskSubmissionProvider'
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
    return studentTaskSubmission(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudentTaskSubmissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentTaskSubmissionHash() =>
    r'e20864103984e064810a257bd980686408c19490';

final class StudentTaskSubmissionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  StudentTaskSubmissionFamily._()
      : super(
          retry: null,
          name: r'studentTaskSubmissionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  StudentTaskSubmissionProvider call(
    String taskId,
  ) =>
      StudentTaskSubmissionProvider._(argument: taskId, from: this);

  @override
  String toString() => r'studentTaskSubmissionProvider';
}
