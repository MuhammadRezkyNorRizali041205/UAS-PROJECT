// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../feed/presentation/widgets/like_button.dart';
import '../../../student_class/presentation/screens/student_class_list_screen.dart';
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

        // ── Search bar ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _SearchBar(),
          ),
        ),

        // ── Stats 2×2 grid ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _StatsGrid(data: data),
          ),
        ),

        // ── Tugas UAS Banner ─────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _TugasUasBanner(),
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

        // ── Kelas Saya ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _SectionHeader(
              title: 'Kelas Saya',
              icon: Icons.school_rounded,
              onMore: () => context.push(AppRoutes.studentClasses),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: _MyClassesSection()),

        // ── Social Feed (3 recent posts) ─────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _SectionHeader(
              title: 'Feed Pencapaian',
              icon: Icons.emoji_events_outlined,
              onMore: () => context.push(AppRoutes.feed),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: _RecentFeedSection()),

        // ── Quick Access: Kalender & Presensi ────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _SectionHeader(
              title: 'Akses Cepat',
              icon: Icons.apps_rounded,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _QuickAccessCard(
                    icon: Icons.calendar_month_rounded,
                    label: 'Kalender',
                    color: Colors.blue,
                    onTap: () => context.push(AppRoutes.calendar),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessCard(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Presensi',
                    color: Colors.green,
                    onTap: () => context.push(AppRoutes.attendance),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessCard(
                    icon: Icons.emoji_events_rounded,
                    label: 'Feed',
                    color: Colors.orange,
                    onTap: () => context.push(AppRoutes.feed),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tugas UAS Banner ─────────────────────────────────────────────────────────
class _TugasUasBanner extends StatelessWidget {
  const _TugasUasBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.tugasUasMataKuliah),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengumpulan Tugas UAS',
                      style: TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Kumpulkan tugas ujian mata kuliah Anda',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  final String greeting;
  const _Header({required this.greeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = greeting.split(', ');
    final greetPart = parts.length > 1 ? '${parts[0]},' : greeting;
    final namePart  = parts.length > 1 ? parts[1] : '';

    final unread = ref.watch(notificationUnreadCountProvider).value ?? 0;

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
        GestureDetector(
          onTap: () => context.push('/dashboard/notification'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
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
              if (unread > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                        minWidth: 18, minHeight: 18),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
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
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
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

// ─── Recent Social Feed (3 posts) ────────────────────────────────────────────
class _RecentFeedSection extends ConsumerWidget {
  const _RecentFeedSection();

  static const _typeEmoji = {
    'task_completed':   '✅',
    'streak_milestone': '🔥',
    'badge_earned':     '🏅',
    'level_up':         '⬆️',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(feedProvider);

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (posts) {
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _EmptyChip(
              icon: Icons.emoji_events_outlined,
              label: 'Belum ada pencapaian yang dibagikan',
            ),
          );
        }
        final visible = posts.take(3).toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: visible.map((post) {
              final emoji = _typeEmoji[post.type] ?? '🏆';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(emoji,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(post.userName,
                      style: const TextStyle(fontSize: 12)),
                  trailing: LikeButton(
                    isLiked:    post.isLiked,
                    likesCount: post.likesCount,
                    onTap: () =>
                        ref.read(feedProvider.notifier).toggleLike(post.id),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
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

// ─── Search bar tap target ────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.search),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cari jadwal, tugas, pengumuman...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Kelas Saya Section ───────────────────────────────────────────────────────
class _MyClassesSection extends ConsumerWidget {
  const _MyClassesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myClassesProvider);

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _EmptyChip(
              icon: Icons.school_outlined,
              label: 'Belum terdaftar di kelas manapun',
            ),
          );
        }

        // Urgency banner — if any class has pending tasks, show alert
        final totalPending = list.fold<int>(
            0, (sum, c) => sum + ((c['pending_tasks'] as int?) ?? 0));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (totalPending > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment_late_rounded,
                          color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '$totalPending tugas belum dikumpulkan',
                        style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                itemCount: list.length,
                itemBuilder: (_, i) => _ClassMiniCard(cls: list[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClassMiniCard extends StatelessWidget {
  const _ClassMiniCard({required this.cls});
  final dynamic cls;

  @override
  Widget build(BuildContext context) {
    final pending   = (cls['pending_tasks']  as int?) ?? 0;
    final completed = (cls['completed_tasks'] as int?) ?? 0;
    final total     = (cls['total_tasks']    as int?) ?? 0;

    return GestureDetector(
      onTap: () => context.push('/student/classes/${cls['id']}'),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: pending > 0
                ? AppColors.warning.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.roleStudent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppColors.roleStudent, size: 16),
                ),
                const Spacer(),
                if (pending > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$pending',
                        style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cls['course_name'] ?? '',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (total > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? completed / total : 0,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$completed/$total tugas',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
