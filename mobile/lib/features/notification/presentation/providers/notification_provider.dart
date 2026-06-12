// lib/features/notification/presentation/providers/notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';

part 'notification_provider.g.dart';

// ── Unread count ───────────────────────────────────────────────────────────

@riverpod
Future<int> notificationUnreadCount(Ref ref) async {
  final result =
      await ref.watch(notificationRepositoryProvider).getUnreadCount();
  return result.when(
    success: (count) => count,
    failure: (_, __) => 0,
  );
}

// ── Feed (paginated list with type filter) ─────────────────────────────────

@riverpod
class NotificationFeed extends _$NotificationFeed {
  String? _type;
  int _page = 1;
  bool _hasMore = false;

  String? get currentType => _type;
  bool get hasMore => _hasMore;

  @override
  Future<List<NotificationModel>> build() async {
    _type = null;
    _page = 1;
    _hasMore = false;
    return _fetchPage(reset: true);
  }

  Future<List<NotificationModel>> _fetchPage({required bool reset}) async {
    final result = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(type: _type, page: _page);

    return result.when(
      success: (data) {
        final rawItems = data['data'] as List<dynamic>? ?? [];
        final items = rawItems
            .map((e) =>
                NotificationModel.fromJson(e as Map<String, dynamic>))
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

  Future<void> changeType(String? type) async {
    if (_type == type) return;
    _type = type == 'all' ? null : type;
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
        .read(notificationRepositoryProvider)
        .getNotifications(type: _type, page: _page);

    result.when(
      success: (data) {
        final rawItems = data['data'] as List<dynamic>? ?? [];
        final items = rawItems
            .map((e) =>
                NotificationModel.fromJson(e as Map<String, dynamic>))
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

  Future<void> markRead(int id) async {
    final result =
        await ref.read(notificationRepositoryProvider).markRead(id);
    result.when(
      success: (_) {
        final updated = (state.valueOrNull ?? []).map((n) {
          if (n.id == id) {
            return NotificationModel(
              id: n.id,
              type: n.type,
              typeLabel: n.typeLabel,
              title: n.title,
              body: n.body,
              isRead: true,
              readAt: n.readAt,
              relativeTime: n.relativeTime,
              createdAt: n.createdAt,
              meta: n.meta,
            );
          }
          return n;
        }).toList();
        state = AsyncData(updated);
        ref.invalidate(notificationUnreadCountProvider);
      },
      failure: (_, __) {},
    );
  }

  Future<void> markAllRead() async {
    final result =
        await ref.read(notificationRepositoryProvider).markAllRead();
    result.when(
      success: (_) {
        final updated = (state.valueOrNull ?? []).map((n) {
          return NotificationModel(
            id: n.id,
            type: n.type,
            typeLabel: n.typeLabel,
            title: n.title,
            body: n.body,
            isRead: true,
            readAt: n.readAt,
            relativeTime: n.relativeTime,
            createdAt: n.createdAt,
            meta: n.meta,
          );
        }).toList();
        state = AsyncData(updated);
        ref.invalidate(notificationUnreadCountProvider);
      },
      failure: (_, __) {},
    );
  }

  Future<void> deleteNotification(int id) async {
    final result =
        await ref.read(notificationRepositoryProvider).deleteNotification(id);
    result.when(
      success: (_) {
        final updated =
            (state.valueOrNull ?? []).where((n) => n.id != id).toList();
        state = AsyncData(updated);
        ref.invalidate(notificationUnreadCountProvider);
      },
      failure: (_, __) {},
    );
  }
}
