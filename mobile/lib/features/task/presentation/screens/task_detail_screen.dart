// lib/features/task/presentation/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/countdown_widget.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../../../feed/presentation/providers/feed_providers.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String id;
  const TaskDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskId = int.tryParse(id);
    if (taskId == null) {
      return const Scaffold(
          body: ErrorState(message: 'ID tugas tidak valid.'));
    }

    final state = ref.watch(taskByIdProvider(taskId));
    return state.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Padding(
            padding: EdgeInsets.all(16), child: SkeletonList(count: 5)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: ErrorState(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(taskByIdProvider(taskId)),
        ),
      ),
      data: (task) => _DetailContent(task: task),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final TaskEntity task;
  const _DetailContent({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = AppColors.priorityColor(task.priority);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      priorityColor.withValues(alpha: 0.15),
                      AppColors.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        AppBadge.priority(task.priority),
                        const SizedBox(width: 8),
                        AppBadge.status(task.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: AppTextStyles.headingLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () =>
                    context.push(AppRoutes.taskEdit(task.id.toString())),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded,
                    color: AppColors.danger),
                onPressed: () => _showDeleteSheet(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick status toggle
                  _StatusToggleCard(task: task),
                  const SizedBox(height: 16),
                  // Info card
                  _InfoCard(task: task),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DescriptionCard(description: task.description!),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.delete_outline_rounded,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text('Hapus Tugas?', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              'Hapus "${task.title}"?\nTindakan ini tidak dapat dibatalkan.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final err = await ref
                          .read(taskListProvider.notifier)
                          .deleteTask(task.id);
                      if (context.mounted) {
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        } else {
                          context.pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatusToggleCard extends ConsumerWidget {
  final TaskEntity task;
  const _StatusToggleCard({required this.task});

  static const _statuses = [
    ('pending', 'Belum Mulai', Icons.radio_button_unchecked_rounded),
    ('in_progress', 'Dikerjakan', Icons.pending_rounded),
    ('completed', 'Selesai', Icons.check_circle_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status', style: AppTextStyles.labelMedium),
          const SizedBox(height: 12),
          Row(
            children: _statuses.map((s) {
              final selected = task.status == s.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (selected) return;
                    final newStatus = s.$1;
                    final err = await ref
                        .read(taskListProvider.notifier)
                        .updateStatus(task.id, newStatus);
                    if (!context.mounted) return;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(err),
                            backgroundColor: AppColors.danger),
                      );
                    } else if (newStatus == 'completed') {
                      _showShareFeedDialog(context, ref, task);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(s.$3,
                            size: 20,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted),
                        const SizedBox(height: 4),
                        Text(
                          s.$2,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showShareFeedDialog(
      BuildContext context, WidgetRef ref, TaskEntity task) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Tugas Selesai!'),
        content: Text(
          'Bagikan pencapaian "${task.title}" ke Social Feed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(feedProvider.notifier).createPost(
                    type:        'task_completed',
                    title:       'Tugas selesai: ${task.title}',
                    description: task.description ?? '',
                    visibility:  'public',
                    achievementData: {
                      'task_id':  task.id,
                      'priority': task.priority,
                    },
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('✅ Dibagikan ke Feed!')),
                );
              }
            },
            child: const Text('Bagikan'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TaskEntity task;
  const _InfoCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (task.deadline != null) ...[
            _Row(Icons.schedule_rounded,
                task.deadlineFormatted ?? task.deadline!.toLocal().toString()),
            if (!task.isCompleted) ...[
              const SizedBox(height: 8),
              CountdownWidget(deadline: task.deadline!),
            ],
            const Divider(height: 24),
          ],
          _Row(Icons.flag_outlined, task.priorityLabel),
          if (task.category != null) ...[
            const Divider(height: 24),
            _Row(Icons.folder_outlined, task.category!.name),
          ],
          if (task.isOverdue) ...[
            const Divider(height: 24),
            const _Row(Icons.warning_amber_rounded, 'Terlambat',
                color: AppColors.danger),
          ],
          if (task.completedAt != null) ...[
            const Divider(height: 24),
            _Row(Icons.check_circle_outline_rounded,
                'Selesai ${_formatDate(task.completedAt!)}',
                color: AppColors.success),
          ],
          const Divider(height: 24),
          _Row(Icons.calendar_today_rounded,
              'Dibuat ${_formatDate(task.createdAt)}'),
        ],
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

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _Row(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon,
              size: 18,
              color: color ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: color)),
          ),
        ],
      );
}

class _DescriptionCard extends StatelessWidget {
  final String description;
  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deskripsi', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Text(description, style: AppTextStyles.bodyMedium),
          ],
        ),
      );
}
