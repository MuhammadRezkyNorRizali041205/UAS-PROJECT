// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRemoteDatasource)
final notificationRemoteDatasourceProvider =
    NotificationRemoteDatasourceProvider._();

final class NotificationRemoteDatasourceProvider extends $FunctionalProvider<
    NotificationRemoteDatasource,
    NotificationRemoteDatasource,
    NotificationRemoteDatasource> with $Provider<NotificationRemoteDatasource> {
  NotificationRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<NotificationRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationRemoteDatasource create(Ref ref) {
    return notificationRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRemoteDatasource>(value),
    );
  }
}

String _$notificationRemoteDatasourceHash() =>
    r'e92c4328a8c6a131409fb2bb81df18a518ca6433';
