// lib/features/schedule/presentation/screens/schedule_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/schedule.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_card.dart';

class ScheduleListScreen extends ConsumerWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Jadwal'),
          bottom: TabBar(
            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
            unselectedLabelStyle: AppTextStyles.labelMedium,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.border,
            tabs: const [
              Tab(text: 'Hari Ini'),
              Tab(text: 'Minggu Ini'),
              Tab(text: 'Semua'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TodayTab(ref: ref),
            _WeekTab(ref: ref),
            _AllTab(ref: ref),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.scheduleCreate),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Today tab ────────────────────────────────────────────────────────────────
class _TodayTab extends ConsumerWidget {
  final WidgetRef ref;
  const _TodayTab({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todaySchedulesProvider);
    return state.when(
      loading: () => const _ScheduleSkeleton(),
      error: (e, _) => ErrorState(
        message: e.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(todaySchedulesProvider),
      ),
      data: (schedules) => schedules.isEmpty
          ? const EmptyState(
              icon: Icons.today_rounded,
              title: 'Tidak ada jadwal hari ini',
              subtitle: 'Nikmati hari bebasmu!',
            )
          : _ScheduleListView(schedules: schedules),
    );
  }
}

// ─── Week tab ─────────────────────────────────────────────────────────────────
class _WeekTab extends ConsumerWidget {
  final WidgetRef ref;
  const _WeekTab({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weekSchedulesProvider);
    return state.when(
      loading: () => const _ScheduleSkeleton(),
      error: (e, _) => ErrorState(
        message: e.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(weekSchedulesProvider),
      ),
      data: (schedules) => schedules.isEmpty
          ? const EmptyState(
              icon: Icons.calendar_view_week_rounded,
              title: 'Tidak ada jadwal minggu ini',
              subtitle: 'Belum ada jadwal untuk 7 hari ke depan.',
            )
          : _ScheduleListView(schedules: schedules),
    );
  }
}

// ─── All tab ──────────────────────────────────────────────────────────────────
class _AllTab extends ConsumerWidget {
  final WidgetRef ref;
  const _AllTab({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleListProvider);
    return state.when(
      loading: () => const _ScheduleSkeleton(),
      error: (e, _) => ErrorState(
        message: e.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(scheduleListProvider),
      ),
      data: (schedules) => schedules.isEmpty
          ? EmptyState(
              icon: Icons.calendar_today_rounded,
              title: 'Belum ada jadwal',
              subtitle: 'Tambahkan jadwal kuliah, praktikum, atau kegiatan lainnya.',
              ctaLabel: 'Tambah Jadwal',
              onCta: () => context.push(AppRoutes.scheduleCreate),
            )
          : _DismissibleScheduleList(schedules: schedules),
    );
  }
}

// ─── Dismissible list (swipe-to-delete) ──────────────────────────────────────
class _DismissibleScheduleList extends ConsumerWidget {
  final List<ScheduleEntity> schedules;
  const _DismissibleScheduleList({required this.schedules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final schedule = schedules[i];
        return Dismissible(
          key: ValueKey(schedule.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context, schedule.title),
          onDismissed: (_) async {
            final err = await ref
                .read(scheduleListProvider.notifier)
                .deleteSchedule(schedule.id);
            if (err != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(err), backgroundColor: AppColors.danger),
              );
            }
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_rounded, color: AppColors.danger),
          ),
          child: ScheduleCard(
            schedule: schedule,
            onTap: () =>
                context.push(AppRoutes.scheduleDetail(schedule.id.toString())),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Jadwal?'),
            content: Text('Hapus "$title"? Tindakan ini tidak dapat dibatalkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ─── Simple list (no swipe) ───────────────────────────────────────────────────
class _ScheduleListView extends StatelessWidget {
  final List<ScheduleEntity> schedules;
  const _ScheduleListView({required this.schedules});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = schedules[i];
        return ScheduleCard(
          schedule: s,
          onTap: () =>
              context.push(AppRoutes.scheduleDetail(s.id.toString())),
        );
      },
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────
class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(count: 5),
      );
}
