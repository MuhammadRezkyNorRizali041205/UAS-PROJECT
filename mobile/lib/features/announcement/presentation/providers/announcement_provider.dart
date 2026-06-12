// lib/features/announcement/presentation/providers/announcement_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/announcement_model.dart';
import '../../data/repositories/announcement_repository_impl.dart';

part 'announcement_provider.g.dart';

// ── Feed (paginated list with category filter) ─────────────────────────────

@riverpod
class AnnouncementFeed extends _$AnnouncementFeed {
  String _category = 'all';
  int _page = 1;
  bool _hasMore = false;

  String get currentCategory => _category;
  bool get hasMore => _hasMore;

  @override
  Future<List<AnnouncementModel>> build() async {
    _category = 'all';
    _page = 1;
    _hasMore = false;
    return _fetchPage(reset: true);
  }

  Future<List<AnnouncementModel>> _fetchPage({required bool reset}) async {
    final result = await ref
        .read(announcementRepositoryProvider)
        .getAnnouncements(category: _category, page: _page);

    return result.when(
      success: (data) {
        final rawItems = data['data'] as List<dynamic>? ?? [];
        final items = rawItems
            .map((e) =>
                AnnouncementModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final meta = data['meta'] as Map<String, dynamic>?;
        final currentPage = (meta?['current_page'] as num?)?.toInt() ?? 1;
        final lastPage = (meta?['last_page'] as num?)?.toInt() ?? 1;
        _hasMore = currentPage < lastPage;

        if (reset) return items;
        return [...(state.valueOrNull ?? []), ...items];
      },
      failure: (msg, _) => throw Exception(msg),
    );
  }

  Future<void> changeCategory(String category) async {
    if (_category == category) return;
    _category = category;
    _page = 1;
    _hasMore = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(reset: true));
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) return;
    final existing = state.valueOrNull ?? [];
    _page++;
    final result = await ref
        .read(announcementRepositoryProvider)
        .getAnnouncements(category: _category, page: _page);

    result.when(
      success: (data) {
        final rawItems = data['data'] as List<dynamic>? ?? [];
        final items = rawItems
            .map((e) =>
                AnnouncementModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final meta = data['meta'] as Map<String, dynamic>?;
        final currentPage = (meta?['current_page'] as num?)?.toInt() ?? 1;
        final lastPage = (meta?['last_page'] as num?)?.toInt() ?? 1;
        _hasMore = currentPage < lastPage;
        state = AsyncData([...existing, ...items]);
      },
      failure: (msg, _) => _page--,
    );
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(reset: true));
  }
}

// ── Detail ─────────────────────────────────────────────────────────────────

@riverpod
class AnnouncementDetail extends _$AnnouncementDetail {
  @override
  FutureOr<AnnouncementModel?> build() => null;

  Future<void> load(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(announcementRepositoryProvider).getById(id);
      return result.when(
        success: (a) => a as AnnouncementModel,
        failure: (msg, _) => throw Exception(msg),
      );
    });
  }
}
