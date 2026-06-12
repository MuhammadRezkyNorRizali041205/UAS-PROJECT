// lib/features/announcement/presentation/screens/announcement_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/skeleton_loader.dart';
import '../providers/announcement_provider.dart';

class AnnouncementDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const AnnouncementDetailScreen({super.key, required this.id});

  @override
  ConsumerState<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState
    extends ConsumerState<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(announcementDetailProvider.notifier).load(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(announcementDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: detailAsync.when(
        loading: () => const _DetailSkeleton(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(
                e.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        data: (announcement) {
          if (announcement == null) return const SizedBox.shrink();

          final catColor = _parseColor(announcement.categoryColor);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Badges ────────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Badge(label: announcement.categoryLabel, color: catColor),
                    if (announcement.isUrgent)
                      const _Badge(label: '🚨 Urgent', color: AppColors.danger),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Title ─────────────────────────────────────────────
                Text(
                  announcement.title,
                  style: AppTextStyles.headingLarge.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 12),

                // ── Author + date ─────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      announcement.authorName,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      announcement.publishedAtFormatted ?? '',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, thickness: 1),
                const SizedBox(height: 16),

                // ── Body ──────────────────────────────────────────────
                SelectableText(
                  announcement.body ?? announcement.contentPreview,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
                ),

                // ── Expiry notice ─────────────────────────────────────
                if (announcement.expiresAt != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Berlaku hingga: ${announcement.expiresAt}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 24, borderRadius: 6),
          SizedBox(height: 16),
          SkeletonBox(height: 28, borderRadius: 6),
          SizedBox(height: 8),
          SkeletonBox(width: 200, height: 20, borderRadius: 6),
          SizedBox(height: 16),
          SkeletonBox(width: 160, height: 16, borderRadius: 6),
          SizedBox(height: 20),
          SkeletonBox(height: 200, borderRadius: 8),
        ],
      ),
    );
  }
}
