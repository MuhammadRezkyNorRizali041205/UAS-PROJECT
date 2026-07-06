// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tugas_profil_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tugasProfil)
final tugasProfilProvider = TugasProfilProvider._();

final class TugasProfilProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  TugasProfilProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tugasProfilProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tugasProfilHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return tugasProfil(ref);
  }
}

String _$tugasProfilHash() => r'5646c615802ed2d445b17a010d1b051d6d94cf5d';
