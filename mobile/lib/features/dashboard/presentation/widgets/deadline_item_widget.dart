// lib/features/dashboard/presentation/widgets/deadline_item_widget.dart

import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_badge.dart';
import '../../../../../shared/widgets/countdown_widget.dart';
import '../../domain/entities/dashboard_data.dart';

class DeadlineItem extends StatelessWidget {
  final DashboardDeadlineItem item;
  final VoidCallback? onTap;

  const DeadlineItem({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Left: title + countdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  CountdownWidget(deadline: item.deadline),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppBadge.priority(item.priority),
          ],
        ),
      ),
    );
  }
}
