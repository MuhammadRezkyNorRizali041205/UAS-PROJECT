// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer_grading_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allPendingGrading)
final allPendingGradingProvider = AllPendingGradingProvider._();

final class AllPendingGradingProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  AllPendingGradingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allPendingGradingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allPendingGradingHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return allPendingGrading(ref);
  }
}

String _$allPendingGradingHash() => r'c101a69da8b90e366d0674795966ba28174bbd04';
