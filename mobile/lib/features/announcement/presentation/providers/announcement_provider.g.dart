// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnnouncementFeed)
final announcementFeedProvider = AnnouncementFeedProvider._();

final class AnnouncementFeedProvider
    extends $AsyncNotifierProvider<AnnouncementFeed, List<AnnouncementModel>> {
  AnnouncementFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'announcementFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$announcementFeedHash();

  @$internal
  @override
  AnnouncementFeed create() => AnnouncementFeed();
}

String _$announcementFeedHash() => r'adf234c39122846c539363d78f33606b4c5908e5';

abstract class _$AnnouncementFeed
    extends $AsyncNotifier<List<AnnouncementModel>> {
  FutureOr<List<AnnouncementModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<AnnouncementModel>>, List<AnnouncementModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<AnnouncementModel>>,
            List<AnnouncementModel>>,
        AsyncValue<List<AnnouncementModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(AnnouncementDetail)
final announcementDetailProvider = AnnouncementDetailProvider._();

final class AnnouncementDetailProvider
    extends $AsyncNotifierProvider<AnnouncementDetail, AnnouncementModel?> {
  AnnouncementDetailProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'announcementDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$announcementDetailHash();

  @$internal
  @override
  AnnouncementDetail create() => AnnouncementDetail();
}

String _$announcementDetailHash() =>
    r'124e03fe1e2eef33cb810c20b2e444bb0d6748b8';

abstract class _$AnnouncementDetail extends $AsyncNotifier<AnnouncementModel?> {
  FutureOr<AnnouncementModel?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AnnouncementModel?>, AnnouncementModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AnnouncementModel?>, AnnouncementModel?>,
        AsyncValue<AnnouncementModel?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
