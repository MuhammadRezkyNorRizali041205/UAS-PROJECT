// lib/features/task/presentation/widgets/task_card.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/countdown_widget.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusToggle;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppColors.priorityColor(task.priority);
    final isCompleted = task.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.surface.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isOverdue
                ? AppColors.danger.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Priority bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.textMuted
                      : priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // Checkbox
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: onStatusToggle,
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: AppTextStyles.headingSmall.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppBadge.priority(task.priority),
                        ],
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (task.category != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.folder_outlined,
                                size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              task.category!.name,
                              style: AppTextStyles.labelSmall,
                            ),
                          ],
                        ),
                      ],
                      if (task.deadline != null && !isCompleted) ...[
                        const SizedBox(height: 8),
                        CountdownWidget(deadline: task.deadline!),
                      ],
                      if (isCompleted && task.completedAt != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                size: 12, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Selesai ${_formatDate(task.completedAt!)}',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
