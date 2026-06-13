// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_class_list_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentClassRepository)
final studentClassRepositoryProvider = StudentClassRepositoryProvider._();

final class StudentClassRepositoryProvider extends $FunctionalProvider<
    StudentClassRepository,
    StudentClassRepository,
    StudentClassRepository> with $Provider<StudentClassRepository> {
  StudentClassRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'studentClassRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studentClassRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudentClassRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudentClassRepository create(Ref ref) {
    return studentClassRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudentClassRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudentClassRepository>(value),
    );
  }
}

String _$studentClassRepositoryHash() =>
    r'c361b2288941ae221f46d67f066850a483f651a4';

@ProviderFor(myClasses)
final myClassesProvider = MyClassesProvider._();

final class MyClassesProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  MyClassesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'myClassesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$myClassesHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return myClasses(ref);
  }
}

String _$myClassesHash() => r'1b32075ba1066172e8c294005e0a85935d7e3528';
