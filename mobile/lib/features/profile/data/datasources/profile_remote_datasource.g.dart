// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRemoteDatasource)
final profileRemoteDatasourceProvider = ProfileRemoteDatasourceProvider._();

final class ProfileRemoteDatasourceProvider extends $FunctionalProvider<
    ProfileRemoteDatasource,
    ProfileRemoteDatasource,
    ProfileRemoteDatasource> with $Provider<ProfileRemoteDatasource> {
  ProfileRemoteDatasourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileRemoteDatasourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<ProfileRemoteDatasource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileRemoteDatasource create(Ref ref) {
    return profileRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRemoteDatasource>(value),
    );
  }
}

String _$profileRemoteDatasourceHash() =>
    r'6ef5d3f9f46208f0775423b6ab77316f7f0861fa';
