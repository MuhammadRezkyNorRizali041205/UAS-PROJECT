// lib/features/announcement/presentation/screens/announcement_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/skeleton_loader.dart';
import '../../data/models/announcement_model.dart';
import '../providers/announcement_provider.dart';

class AnnouncementFeedScreen extends ConsumerStatefulWidget {
  const AnnouncementFeedScreen({super.key});

  @override
  ConsumerState<AnnouncementFeedScreen> createState() =>
      _AnnouncementFeedScreenState();
}

class _AnnouncementFeedScreenState
    extends ConsumerState<AnnouncementFeedScreen> {
  final _scrollController = ScrollController();

  static const _categories = [
    ('all', 'Semua'),
    ('academic', '📚 Akademik'),
    ('event', '🎉 Event'),
    ('seminar', '🎤 Seminar'),
    ('urgent', '🚨 Urgent'),
    ('general', '📋 Umum'),
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
      ref.read(announcementFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(announcementFeedProvider.notifier);
    final feedAsync = ref.watch(announcementFeedProvider);
    final currentCat = notifier.currentCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Column(
        children: [
          // ── Category chips ───────────────────────────────────────────
          _CategoryChips(
            categories: _categories,
            current: currentCat,
            onSelect: notifier.changeCategory,
          ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: feedAsync.when(
              loading: () => const _FeedSkeleton(),
              error: (e, _) => ErrorState(
                message: e.toString().replaceFirst('Exception: ', ''),
                onRetry: notifier.refresh,
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'Belum ada pengumuman',
                    subtitle: currentCat == 'all'
                        ? 'Pengumuman akan muncul di sini'
                        : 'Tidak ada pengumuman untuk kategori ini',
                  );
                }

                final urgentItems =
                    items.where((a) => a.isUrgent).toList();

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: notifier.refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length +
                        (urgentItems.isNotEmpty ? 1 : 0) +
                        (notifier.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Urgent banner at top
                      if (urgentItems.isNotEmpty && index == 0) {
                        return _UrgentBanner(
                            count: urgentItems.length);
                      }
                      final offset = urgentItems.isNotEmpty ? 1 : 0;
                      final itemIndex = index - offset;

                      // Load more spinner at end
                      if (itemIndex >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2)),
                        );
                      }

                      return _AnnouncementCard(
                        announcement: items[itemIndex],
                        onTap: () => context.push(
                          '/dashboard/announcement/${items[itemIndex].id}',
                        ),
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

// ─── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<(String, String)> categories;
  final String current;
  final void Function(String) onSelect;

  const _CategoryChips({
    required this.categories,
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
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label) = categories[i];
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

// ─── Urgent banner ────────────────────────────────────────────────────────────

class _UrgentBanner extends StatelessWidget {
  final int count;
  const _UrgentBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count == 1
                  ? 'Ada 1 pengumuman penting!'
                  : 'Ada $count pengumuman penting!',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Announcement card ────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = _parseColor(announcement.categoryColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: announcement.isUrgent
                ? AppColors.danger.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges row
            Row(
              children: [
                _Badge(
                  label: announcement.categoryLabel,
                  color: catColor,
                ),
                if (announcement.isUrgent) ...[
                  const SizedBox(width: 6),
                  _Badge(label: '🚨 Urgent', color: AppColors.danger),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              announcement.title,
              style: AppTextStyles.labelLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Preview
            Text(
              announcement.contentPreview,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Footer
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    announcement.authorName,
                    style: AppTextStyles.bodySmall
                        .copyWith(
                            color: AppColors.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  announcement.publishedAtFormatted ?? '',
                  style: AppTextStyles.bodySmall
                      .copyWith(
                          color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 14, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(
          int.parse(hex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 6,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: SkeletonBox(height: 110, borderRadius: 14),
      ),
    );
  }
}
