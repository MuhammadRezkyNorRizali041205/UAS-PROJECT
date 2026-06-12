// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateProfileUsecase)
final updateProfileUsecaseProvider = UpdateProfileUsecaseProvider._();

final class UpdateProfileUsecaseProvider extends $FunctionalProvider<
    UpdateProfileUsecase,
    UpdateProfileUsecase,
    UpdateProfileUsecase> with $Provider<UpdateProfileUsecase> {
  UpdateProfileUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateProfileUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateProfileUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProfileUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProfileUsecase create(Ref ref) {
    return updateProfileUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfileUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfileUsecase>(value),
    );
  }
}

String _$updateProfileUsecaseHash() =>
    r'9b463049cd4d02cfb14e086ceca941b94f14a122';
