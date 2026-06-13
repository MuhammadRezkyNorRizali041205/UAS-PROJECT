// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_class_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentClassDetail)
final studentClassDetailProvider = StudentClassDetailFamily._();

final class StudentClassDetailProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  StudentClassDetailProvider._(
      {required StudentClassDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'studentClassDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studentClassDetailHash();

  @override
  String toString() {
    return r'studentClassDetailProvider'
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
    return studentClassDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudentClassDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentClassDetailHash() =>
    r'cb654acbb34274430efd6673a13b1af6457ecd71';

final class StudentClassDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  StudentClassDetailFamily._()
      : super(
          retry: null,
          name: r'studentClassDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  StudentClassDetailProvider call(
    String classId,
  ) =>
      StudentClassDetailProvider._(argument: classId, from: this);

  @override
  String toString() => r'studentClassDetailProvider';
}
