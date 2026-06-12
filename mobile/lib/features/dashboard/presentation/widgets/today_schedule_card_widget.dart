// lib/features/dashboard/presentation/widgets/today_schedule_card_widget.dart

import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/dashboard_data.dart';

class TodayScheduleCard extends StatelessWidget {
  final DashboardScheduleItem schedule;
  final VoidCallback? onTap;

  const TodayScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
  });

  Color get _color {
    final hex = schedule.categoryColor.replaceFirst('#', '');
    final val = int.tryParse(hex, radix: 16);
    return val != null ? Color(0xFF000000 | val) : AppColors.primary;
  }

  String get _categoryLabel {
    switch (schedule.category) {
      case 'lecture':      return 'Kuliah';
      case 'practicum':    return 'Praktikum';
      case 'seminar':      return 'Seminar';
      case 'organization': return 'Organisasi';
      case 'task':         return 'Tugas';
      case 'exam':         return 'Ujian';
      default:             return schedule.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _categoryLabel,
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ),
            const SizedBox(height: 10),
            // Time
            Text(
              '${schedule.startTime} – ${schedule.endTime}',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              schedule.title,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (schedule.room != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.room_outlined,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      schedule.room!,
                      style: AppTextStyles.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
