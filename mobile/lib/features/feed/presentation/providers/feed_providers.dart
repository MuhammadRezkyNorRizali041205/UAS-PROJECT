// lib/features/feed/presentation/providers/feed_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/feed_post_model.dart';
import '../../domain/entities/feed_post.dart';

part 'feed_providers.g.dart';

// ─── Remote helper ─────────────────────────────────────────────────────────────

Future<List<FeedPost>> _fetchFeed(DioClient client, {int page = 1}) async {
  final res = await client.get<Map<String, dynamic>>(
    '/feed',
    queryParameters: {'page': page},
    fromJson: (d) => d as Map<String, dynamic>,
  );
  return (res['data'] as List)
      .map((e) => FeedPostModel.fromJson(e as Map<String, dynamic>).toEntity())
      .toList();
}

// ─── Feed notifier ─────────────────────────────────────────────────────────────

@riverpod
class FeedNotifier extends _$FeedNotifier {
  int  _page    = 1;
  bool _hasMore = true;

  @override
  Future<List<FeedPost>> build() async {
    _page    = 1;
    _hasMore = true;
    return _fetchFeed(ref.read(dioClientProvider));
  }

  Future<void> refresh() async {
    _page    = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _fetchFeed(ref.read(dioClientProvider)));
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final more = await _fetchFeed(ref.read(dioClientProvider), page: _page);
    if (more.isEmpty) {
      _hasMore = false;
      return;
    }
    final current = state.value ?? [];
    state = AsyncData([...current, ...more]);
  }

  Future<void> toggleLike(String postId) async {
    final client = ref.read(dioClientProvider);
    final res = await client.post<Map<String, dynamic>>(
      '/feed/$postId/like',
      fromJson: (d) => d as Map<String, dynamic>,
    );
    final liked      = res['liked'] as bool;
    final likesCount = (res['likes_count'] as num).toInt();

    state = AsyncData((state.value ?? []).map((p) {
      if (p.id != postId) return p;
      return p.copyWith(likesCount: likesCount, isLiked: liked);
    }).toList());
  }

  Future<void> createPost({
    required String type,
    required String title,
    String description = '',
    String visibility  = 'public',
    Map<String, dynamic>? achievementData,
  }) async {
    final client = ref.read(dioClientProvider);
    final res = await client.post<Map<String, dynamic>>(
      '/feed',
      data: {
        'type':             type,
        'title':            title,
        'description':      description,
        'visibility':       visibility,
        'achievement_data': achievementData,
      },
      fromJson: (d) => d as Map<String, dynamic>,
    );
    final post = FeedPostModel.fromJson(
            res['data'] as Map<String, dynamic>)
        .toEntity();
    final current = state.value ?? [];
    state = AsyncData([post, ...current]);
  }
}
