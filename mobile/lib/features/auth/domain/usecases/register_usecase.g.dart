// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(registerUsecase)
final registerUsecaseProvider = RegisterUsecaseProvider._();

final class RegisterUsecaseProvider extends $FunctionalProvider<RegisterUsecase,
    RegisterUsecase, RegisterUsecase> with $Provider<RegisterUsecase> {
  RegisterUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'registerUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$registerUsecaseHash();

  @$internal
  @override
  $ProviderElement<RegisterUsecase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RegisterUsecase create(Ref ref) {
    return registerUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterUsecase>(value),
    );
  }
}

String _$registerUsecaseHash() => r'5955b218a9dd1f434f4724383544b3705bb9b677';
