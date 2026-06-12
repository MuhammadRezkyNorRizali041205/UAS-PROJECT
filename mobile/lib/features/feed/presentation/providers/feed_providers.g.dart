// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedNotifier)
final feedProvider = FeedNotifierProvider._();

final class FeedNotifierProvider
    extends $AsyncNotifierProvider<FeedNotifier, List<FeedPost>> {
  FeedNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedNotifierHash();

  @$internal
  @override
  FeedNotifier create() => FeedNotifier();
}

String _$feedNotifierHash() => r'7f15c5ea527019f4279e3d473cb6802e2de0773f';

abstract class _$FeedNotifier extends $AsyncNotifier<List<FeedPost>> {
  FutureOr<List<FeedPost>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FeedPost>>, List<FeedPost>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<FeedPost>>, List<FeedPost>>,
        AsyncValue<List<FeedPost>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
