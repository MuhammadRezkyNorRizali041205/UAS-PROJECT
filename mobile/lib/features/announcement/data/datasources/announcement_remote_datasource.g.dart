// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(announcementRemoteDatasource)
final announcementRemoteDatasourceProvider =
    AnnouncementRemoteDatasourceProvider._();

final class AnnouncementRemoteDatasourceProvider extends $FunctionalProvider<
    AnnouncementRemoteDatasource,
    AnnouncementRemoteDatasource,
    AnnouncementRemoteDatasource> with $Provider<AnnouncementRemoteDatasource> {
  AnnouncementRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'announcementRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$announcementRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<AnnouncementRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnnouncementRemoteDatasource create(Ref ref) {
    return announcementRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementRemoteDatasource>(value),
    );
  }
}

String _$announcementRemoteDatasourceHash() =>
    r'5d413b1e1e2a8f89a6cac7090985c97fb8aeb37b';
