// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_notification_prefs_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateNotificationPrefsUsecase)
final updateNotificationPrefsUsecaseProvider =
    UpdateNotificationPrefsUsecaseProvider._();

final class UpdateNotificationPrefsUsecaseProvider extends $FunctionalProvider<
        UpdateNotificationPrefsUsecase,
        UpdateNotificationPrefsUsecase,
        UpdateNotificationPrefsUsecase>
    with $Provider<UpdateNotificationPrefsUsecase> {
  UpdateNotificationPrefsUsecaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateNotificationPrefsUsecaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateNotificationPrefsUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateNotificationPrefsUsecase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateNotificationPrefsUsecase create(Ref ref) {
    return updateNotificationPrefsUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateNotificationPrefsUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<UpdateNotificationPrefsUsecase>(value),
    );
  }
}

String _$updateNotificationPrefsUsecaseHash() =>
    r'43114340631d971622f54d89b65e99b589aeb3ce';
