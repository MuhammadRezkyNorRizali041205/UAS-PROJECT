// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_event_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orgEventDetail)
final orgEventDetailProvider = OrgEventDetailFamily._();

final class OrgEventDetailProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  OrgEventDetailProvider._(
      {required OrgEventDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'orgEventDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orgEventDetailHash();

  @override
  String toString() {
    return r'orgEventDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return orgEventDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrgEventDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orgEventDetailHash() => r'f477c7cb4c750f0b772e4eee0fc4c9ac18ef0110';

final class OrgEventDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  OrgEventDetailFamily._()
      : super(
          retry: null,
          name: r'orgEventDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  OrgEventDetailProvider call(
    String eventId,
  ) =>
      OrgEventDetailProvider._(argument: eventId, from: this);

  @override
  String toString() => r'orgEventDetailProvider';
}

@ProviderFor(orgEventRegistrations)
final orgEventRegistrationsProvider = OrgEventRegistrationsFamily._();

final class OrgEventRegistrationsProvider extends $FunctionalProvider<
        AsyncValue<List<dynamic>>, List<dynamic>, FutureOr<List<dynamic>>>
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  OrgEventRegistrationsProvider._(
      {required OrgEventRegistrationsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'orgEventRegistrationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orgEventRegistrationsHash();

  @override
  String toString() {
    return r'orgEventRegistrationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return orgEventRegistrations(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrgEventRegistrationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orgEventRegistrationsHash() =>
    r'db0bd7dc3b49d329715a6ac8712c8400657d9401';

final class OrgEventRegistrationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, String> {
  OrgEventRegistrationsFamily._()
      : super(
          retry: null,
          name: r'orgEventRegistrationsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  OrgEventRegistrationsProvider call(
    String eventId,
  ) =>
      OrgEventRegistrationsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'orgEventRegistrationsProvider';
}
