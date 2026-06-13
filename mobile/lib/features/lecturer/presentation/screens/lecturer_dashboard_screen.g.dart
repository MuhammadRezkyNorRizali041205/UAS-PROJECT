// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer_dashboard_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lecturerRepository)
final lecturerRepositoryProvider = LecturerRepositoryProvider._();

final class LecturerRepositoryProvider extends $FunctionalProvider<
    LecturerRepository,
    LecturerRepository,
    LecturerRepository> with $Provider<LecturerRepository> {
  LecturerRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lecturerRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lecturerRepositoryHash();

  @$internal
  @override
  $ProviderElement<LecturerRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LecturerRepository create(Ref ref) {
    return lecturerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LecturerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LecturerRepository>(value),
    );
  }
}

String _$lecturerRepositoryHash() =>
    r'3a202186ff5674111123b79a03c5493449676f32';

@ProviderFor(lecturerDashboard)
final lecturerDashboardProvider = LecturerDashboardProvider._();

final class LecturerDashboardProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  LecturerDashboardProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lecturerDashboardProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lecturerDashboardHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return lecturerDashboard(ref);
  }
}

String _$lecturerDashboardHash() => r'65fcf9e347f4f4a320505c6e8838526a686c0180';

@ProviderFor(lecturerClasses)
final lecturerClassesProvider = LecturerClassesProvider._();

final class LecturerClassesProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  LecturerClassesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lecturerClassesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lecturerClassesHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return lecturerClasses(ref);
  }
}

String _$lecturerClassesHash() => r'da3b9771f80969deddd305f17f7ff8257c1b952c';
