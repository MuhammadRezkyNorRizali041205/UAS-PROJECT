// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationUnreadCount)
final notificationUnreadCountProvider = NotificationUnreadCountProvider._();

final class NotificationUnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  NotificationUnreadCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationUnreadCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationUnreadCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return notificationUnreadCount(ref);
  }
}

String _$notificationUnreadCountHash() =>
    r'a76a9166aa4eadf3359290f48f93d17139eb8365';

@ProviderFor(NotificationFeed)
final notificationFeedProvider = NotificationFeedProvider._();

final class NotificationFeedProvider
    extends $AsyncNotifierProvider<NotificationFeed, List<NotificationModel>> {
  NotificationFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationFeedHash();

  @$internal
  @override
  NotificationFeed create() => NotificationFeed();
}

String _$notificationFeedHash() => r'9f176174318ed7772de6efc4bfd4bd2988f5a432';

abstract class _$NotificationFeed
    extends $AsyncNotifier<List<NotificationModel>> {
  FutureOr<List<NotificationModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<NotificationModel>>, List<NotificationModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<NotificationModel>>,
            List<NotificationModel>>,
        AsyncValue<List<NotificationModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
