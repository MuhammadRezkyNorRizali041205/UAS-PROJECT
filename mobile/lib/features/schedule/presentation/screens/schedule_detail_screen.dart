// lib/features/schedule/presentation/screens/schedule_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/schedule.dart';
import '../providers/schedule_provider.dart';

class ScheduleDetailScreen extends ConsumerWidget {
  final String id;
  const ScheduleDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleId = int.tryParse(id);
    if (scheduleId == null) {
      return const Scaffold(body: ErrorState(message: 'ID jadwal tidak valid.'));
    }

    final state = ref.watch(scheduleByIdProvider(scheduleId));
    return state.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Detail Jadwal')),
        body: const Padding(padding: EdgeInsets.all(16), child: SkeletonList(count: 4)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Detail Jadwal')),
        body: ErrorState(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(scheduleByIdProvider(scheduleId)),
        ),
      ),
      data: (schedule) => _DetailContent(schedule: schedule),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final ScheduleEntity schedule;
  const _DetailContent({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.categoryColor(schedule.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      AppColors.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding:
                    const EdgeInsets.fromLTRB(16, 80, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppBadge.category(schedule.category),
                    const SizedBox(height: 4),
                    Text(
                      schedule.title,
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
                onPressed: () => context.push(
                  AppRoutes.scheduleEdit(schedule.id.toString()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: AppColors.danger),
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
                  _InfoCard(schedule: schedule),
                  if (schedule.notes != null &&
                      schedule.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _NotesCard(notes: schedule.notes!),
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
            Text('Hapus Jadwal?', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              'Hapus "${schedule.title}"?\nTindakan ini tidak dapat dibatalkan.',
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
                          .read(scheduleListProvider.notifier)
                          .deleteSchedule(schedule.id);
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
                      backgroundColor: AppColors.danger,
                    ),
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

class _InfoCard extends StatelessWidget {
  final ScheduleEntity schedule;
  const _InfoCard({required this.schedule});

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
          _Row(Icons.schedule_rounded,
              '${schedule.startTime} – ${schedule.endTime} (${schedule.durationMinutes} mnt)'),
          const Divider(height: 24),
          _Row(Icons.today_rounded, schedule.dayName),
          if (schedule.room != null) ...[
            const Divider(height: 24),
            _Row(Icons.room_outlined, schedule.room!),
          ],
          if (schedule.lecturer != null) ...[
            const Divider(height: 24),
            _Row(Icons.person_outline_rounded, schedule.lecturer!),
          ],
          const Divider(height: 24),
          _Row(Icons.repeat_rounded, _recurrenceLabel(schedule.recurrence)),
          const Divider(height: 24),
          _Row(Icons.date_range_rounded,
              'Mulai ${_formatDate(schedule.startDate)}${schedule.endDate != null ? ' – ${_formatDate(schedule.endDate!)}' : ''}'),
          const Divider(height: 24),
          _Row(
            schedule.isActive
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            schedule.isActive ? 'Aktif' : 'Nonaktif',
            color: schedule.isActive ? AppColors.success : AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  String _recurrenceLabel(String r) {
    switch (r) {
      case 'once': return 'Sekali';
      case 'weekly': return 'Setiap minggu';
      case 'biweekly': return 'Dua minggu sekali';
      default: return r;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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
            child: Text(
              text,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: color),
            ),
          ),
        ],
      );
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

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
            Text('Catatan', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Text(notes, style: AppTextStyles.bodyMedium),
          ],
        ),
      );
}
