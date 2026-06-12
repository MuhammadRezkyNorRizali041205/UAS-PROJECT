// lib/features/notification/presentation/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/skeleton_loader.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final _scrollController = ScrollController();

  static const _filters = [
    ('all', 'Semua'),
    ('task', '✅ Tugas'),
    ('schedule', '📅 Jadwal'),
    ('announcement', '📢 Pengumuman'),
    ('achievement', '🏆 Pencapaian'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(notificationFeedProvider.notifier);
    final feedAsync = ref.watch(notificationFeedProvider);
    final currentType = notifier.currentType ?? 'all';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          feedAsync.whenOrNull(
            data: (items) {
              final hasUnread = items.any((n) => !n.isRead);
              if (!hasUnread) return null;
              return TextButton(
                onPressed: notifier.markAllRead,
                child: Text(
                  'Baca Semua',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary),
                ),
              );
            },
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: Column(
        children: [
          // ── Filter chips ─────────────────────────────────────────────
          _FilterChips(
            filters: _filters,
            current: currentType,
            onSelect: notifier.changeType,
          ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: feedAsync.when(
              loading: () => const _NotifSkeleton(),
              error: (e, _) => ErrorState(
                message: e.toString().replaceFirst('Exception: ', ''),
                onRetry: notifier.refresh,
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'Tidak ada notifikasi',
                    subtitle: currentType == 'all'
                        ? 'Notifikasi baru akan muncul di sini'
                        : 'Tidak ada notifikasi untuk kategori ini',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: notifier.refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount:
                        items.length + (notifier.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2)),
                        );
                      }
                      return _NotificationTile(
                        notification: items[index],
                        onTap: () =>
                            notifier.markRead(items[index].id),
                        onDismiss: () =>
                            notifier.deleteNotification(items[index].id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final List<(String, String)> filters;
  final String current;
  final void Function(String?) onSelect;

  const _FilterChips({
    required this.filters,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label) = filters[i];
          final selected = key == current;
          return GestureDetector(
            onTap: () => onSelect(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surface
                : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _typeColor(notification.type)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _typeIcon(notification.type),
                  size: 20,
                  color: _typeColor(notification.type),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type label + unread dot
                    Row(
                      children: [
                        Text(
                          notification.typeLabel,
                          style: AppTextStyles.labelSmall
                              .copyWith(
                                  color:
                                      _typeColor(notification.type)),
                        ),
                        const Spacer(),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Title
                    Text(
                      notification.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Body
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Time
                    Text(
                      notification.relativeTime ??
                          notification.createdAt ??
                          '',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'task' => Icons.task_alt_rounded,
      'schedule' => Icons.calendar_today_rounded,
      'announcement' => Icons.campaign_rounded,
      'achievement' => Icons.emoji_events_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  Color _typeColor(String type) {
    return switch (type) {
      'task' => AppColors.success,
      'schedule' => AppColors.primary,
      'announcement' => AppColors.warning,
      'achievement' => const Color(0xFFF59E0B),
      _ => AppColors.textSecondary,
    };
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _NotifSkeleton extends StatelessWidget {
  const _NotifSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 8,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: SkeletonBox(height: 90, borderRadius: 14),
      ),
    );
  }
}
