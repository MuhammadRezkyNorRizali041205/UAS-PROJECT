// lib/features/schedule/presentation/widgets/schedule_card.dart
import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_badge.dart';
import '../../domain/entities/schedule.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleEntity schedule;
  final VoidCallback? onTap;

  const ScheduleCard({super.key, required this.schedule, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(schedule.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color border
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              schedule.title,
                              style: AppTextStyles.headingSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppBadge.category(schedule.category),
                        ],
                      ),
                      if (schedule.room != null) ...[
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.room_outlined,
                          text: schedule.room!,
                        ),
                      ],
                      if (schedule.lecturer != null) ...[
                        const SizedBox(height: 2),
                        _InfoRow(
                          icon: Icons.person_outline_rounded,
                          text: schedule.lecturer!,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _TimeChip(
                            '${schedule.startTime} – ${schedule.endTime}',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${schedule.durationMinutes} mnt',
                            style: AppTextStyles.labelSmall,
                          ),
                          const Spacer(),
                          if (!schedule.isActive)
                            const _InactiveChip(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

class _TimeChip extends StatelessWidget {
  final String label;
  const _TimeChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall
              .copyWith(color: AppColors.primaryLight),
        ),
      );
}

class _InactiveChip extends StatelessWidget {
  const _InactiveChip();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Nonaktif',
          style: AppTextStyles.labelSmall
              .copyWith(color: AppColors.textMuted),
        ),
      );
}
