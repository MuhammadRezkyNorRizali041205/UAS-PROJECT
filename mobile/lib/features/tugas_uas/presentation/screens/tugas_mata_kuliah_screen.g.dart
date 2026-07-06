// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tugas_mata_kuliah_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tugasUasRepository)
final tugasUasRepositoryProvider = TugasUasRepositoryProvider._();

final class TugasUasRepositoryProvider extends $FunctionalProvider<
    TugasUasRepository,
    TugasUasRepository,
    TugasUasRepository> with $Provider<TugasUasRepository> {
  TugasUasRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tugasUasRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tugasUasRepositoryHash();

  @$internal
  @override
  $ProviderElement<TugasUasRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TugasUasRepository create(Ref ref) {
    return tugasUasRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TugasUasRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TugasUasRepository>(value),
    );
  }
}

String _$tugasUasRepositoryHash() =>
    r'1fc29857c29ded244beea4fcfa3111b575f94f1e';

@ProviderFor(mataKuliahSaya)
final mataKuliahSayaProvider = MataKuliahSayaProvider._();

final class MataKuliahSayaProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  MataKuliahSayaProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mataKuliahSayaProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mataKuliahSayaHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return mataKuliahSaya(ref);
  }
}

String _$mataKuliahSayaHash() => r'3e279ab1915dba813c151fec8b17ba7576f1079d';
