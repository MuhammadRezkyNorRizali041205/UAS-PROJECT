// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_dashboard_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orgRepository)
final orgRepositoryProvider = OrgRepositoryProvider._();

final class OrgRepositoryProvider
    extends $FunctionalProvider<OrgRepository, OrgRepository, OrgRepository>
    with $Provider<OrgRepository> {
  OrgRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orgRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orgRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrgRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrgRepository create(Ref ref) {
    return orgRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrgRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrgRepository>(value),
    );
  }
}

String _$orgRepositoryHash() => r'42a402ee89c151487a6ec92a7a7142d4b4ee6dcc';

@ProviderFor(orgDashboard)
final orgDashboardProvider = OrgDashboardProvider._();

final class OrgDashboardProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  OrgDashboardProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orgDashboardProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orgDashboardHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return orgDashboard(ref);
  }
}

String _$orgDashboardHash() => r'1274659ceb734db461c89af41a3809c53c9027ed';

@ProviderFor(orgEvents)
final orgEventsProvider = OrgEventsProvider._();

final class OrgEventsProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  OrgEventsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orgEventsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orgEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return orgEvents(ref);
  }
}

String _$orgEventsHash() => r'371823cb6d319f4f52b45cda5e8851fd550f4e99';

@ProviderFor(orgMembers)
final orgMembersProvider = OrgMembersProvider._();

final class OrgMembersProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  OrgMembersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orgMembersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orgMembersHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return orgMembers(ref);
  }
}

String _$orgMembersHash() => r'1452d0ee9eb2a71fd0e50236a5868a64f28c01f4';
