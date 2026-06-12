// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../domain/entities/dashboard_data.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/deadline_item_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/today_schedule_card_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.when(
          loading: () => const DashboardSkeleton(),
          error: (e, _) => ErrorState(
            message: e.toString().replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(dashboardDataProvider),
          ),
          data: (data) => RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(dashboardDataProvider),
            child: _DashboardBody(data: data),
          ),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  final DashboardData data;
  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _Header(greeting: data.greeting),
          ),
        ),

        // ── Stats 2×2 grid ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _StatsGrid(data: data),
          ),
        ),

        // ── Today's schedules ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _SectionHeader(
              title: 'Jadwal Hari Ini',
              icon: Icons.today_rounded,
              onMore: () => context.go(AppRoutes.schedule),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _TodaySchedulesSection(schedules: data.todaySchedules),
        ),

        // ── Upcoming deadlines ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _SectionHeader(
              title: 'Deadline Terdekat',
              icon: Icons.assignment_late_outlined,
              onMore: () => context.go(AppRoutes.task),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _DeadlinesSection(deadlines: data.upcomingDeadlines),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String greeting;
  const _Header({required this.greeting});

  @override
  Widget build(BuildContext context) {
    // Split "Selamat pagi, Brian!" into greeting + name parts
    final parts = greeting.split(', ');
    final greetPart = parts.length > 1 ? '${parts[0]},' : greeting;
    final namePart  = parts.length > 1 ? parts[1] : '';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greetPart, style: AppTextStyles.bodyMedium),
              Text(
                namePart,
                style: AppTextStyles.displayMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              color: AppColors.primary, size: 22),
        ),
      ],
    );
  }
}

// ─── 2×2 Stats grid ───────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final DashboardData data;
  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = data.weeklyStats;
    final overdueColor =
        stats.overdueTasks > 0 ? AppColors.danger : AppColors.textMuted;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Jadwal Hari Ini',
                value: '${data.todaySchedules.length}',
                icon: Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Task Selesai',
                value: '${stats.completedTasks}',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Overdue',
                value: '${stats.overdueTasks}',
                icon: Icons.warning_amber_rounded,
                color: overdueColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Streak',
                value: '${data.streak} hari',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onMore;
  const _SectionHeader({required this.title, required this.icon, this.onMore});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: AppTextStyles.headingSmall)),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: Text(
                'Lihat semua',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary),
              ),
            ),
        ],
      );
}

// ─── Today schedules (horizontal scroll) ─────────────────────────────────────
class _TodaySchedulesSection extends StatelessWidget {
  final List<DashboardScheduleItem> schedules;
  const _TodaySchedulesSection({required this.schedules});

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: _EmptyChip(
          icon: Icons.check_circle_outline_rounded,
          label: 'Tidak ada jadwal hari ini',
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: schedules.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => TodayScheduleCard(
          schedule: schedules[i],
          onTap: () => context.push(
            AppRoutes.scheduleDetail(schedules[i].id.toString()),
          ),
        ),
      ),
    );
  }
}

// ─── Upcoming deadlines (vertical list) ──────────────────────────────────────
class _DeadlinesSection extends StatelessWidget {
  final List<DashboardDeadlineItem> deadlines;
  const _DeadlinesSection({required this.deadlines});

  @override
  Widget build(BuildContext context) {
    if (deadlines.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: _EmptyChip(
          icon: Icons.celebration_outlined,
          label: 'Tidak ada deadline dalam 7 hari ke depan',
        ),
      );
    }

    final visible = deadlines.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: visible
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DeadlineItem(
                  item: item,
                  onTap: () => context.push(
                    AppRoutes.taskDetail(item.id.toString()),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Empty chip ───────────────────────────────────────────────────────────────
class _EmptyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: AppTextStyles.bodySmall),
            ),
          ],
        ),
      );
}
