// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_avatar_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateAvatarUsecase)
final updateAvatarUsecaseProvider = UpdateAvatarUsecaseProvider._();

final class UpdateAvatarUsecaseProvider extends $FunctionalProvider<
    UpdateAvatarUsecase,
    UpdateAvatarUsecase,
    UpdateAvatarUsecase> with $Provider<UpdateAvatarUsecase> {
  UpdateAvatarUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateAvatarUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateAvatarUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateAvatarUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateAvatarUsecase create(Ref ref) {
    return updateAvatarUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateAvatarUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateAvatarUsecase>(value),
    );
  }
}

String _$updateAvatarUsecaseHash() =>
    r'28332946412e1a8e18138a59b49abf442590f56b';
