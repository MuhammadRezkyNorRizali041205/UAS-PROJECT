// lib/features/lecturer/presentation/screens/lecturer_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/lecturer_repository.dart';

part 'lecturer_dashboard_screen.g.dart';

@riverpod
LecturerRepository lecturerRepository(Ref ref) =>
    LecturerRepository(ref.read(dioClientProvider));

@riverpod
Future<Map<String, dynamic>> lecturerDashboard(Ref ref) =>
    ref.read(lecturerRepositoryProvider).getDashboard();

@riverpod
Future<List<dynamic>> lecturerClasses(Ref ref) =>
    ref.read(lecturerRepositoryProvider).getClasses();

class LecturerDashboardScreen extends ConsumerWidget {
  const LecturerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(lecturerDashboardProvider);
    final classes   = ref.watch(lecturerClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(lecturerDashboardProvider);
            ref.invalidate(lecturerClassesProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              dashboard.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (e, _) => Text('$e', style: const TextStyle(color: AppColors.danger)),
                data:    (d) => _buildStats(d),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Kelas Aktif', onMore: () => context.go('/lecturer/classes')),
              const SizedBox(height: 12),
              classes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (e, _) => Text('$e', style: const TextStyle(color: AppColors.danger)),
                data:    (list) => list.isEmpty
                    ? _buildEmpty('Belum ada kelas')
                    : SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => _ClassCard(cls: list[i]),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              dashboard.when(
                loading: () => const SizedBox.shrink(),
                error:   (_, __) => const SizedBox.shrink(),
                data:    (d) => _buildPendingSection(context, d),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Dosen',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      )),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.roleLecturer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.roleLecturer.withValues(alpha: 0.4)),
                ),
                child: const Text('👨‍🏫 Dosen',
                    style: TextStyle(color: AppColors.roleLecturer, fontSize: 12)),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.roleLecturer.withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: AppColors.roleLecturer),
        ),
      ],
    );
  }

  Widget _buildStats(Map<String, dynamic> d) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(label: 'Total Kelas',      value: '${d['total_classes'] ?? 0}',      icon: Icons.school_rounded,     color: AppColors.primary),
        _StatCard(label: 'Total Mahasiswa',  value: '${d['total_students'] ?? 0}',     icon: Icons.people_rounded,      color: AppColors.success),
        _StatCard(label: 'Perlu Dinilai',    value: '${d['pending_grading'] ?? 0}',    icon: Icons.edit_note_rounded,   color: (d['pending_grading'] ?? 0) > 0 ? AppColors.warning : AppColors.textMuted),
        _StatCard(label: 'Sesi Hari Ini',   value: '${d['today_attendance_sessions'] ?? 0}', icon: Icons.today_rounded, color: AppColors.info),
      ],
    );
  }

  Widget _buildPendingSection(BuildContext context, Map<String, dynamic> d) {
    final submissions = (d['recent_submissions'] as List?) ?? [];
    if (submissions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Perlu Dinilai'),
        const SizedBox(height: 12),
        ...submissions.map((s) => _PendingSubmissionCard(data: s)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        if (onMore != null)
          TextButton(onPressed: onMore, child: const Text('Lihat Semua', style: TextStyle(fontSize: 12))),
      ],
    );
  }

  Widget _buildEmpty(String msg) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(msg, style: const TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});
  final dynamic cls;

  @override
  Widget build(BuildContext context) {
    final completionRate = (cls['completion_rate'] as num?)?.toDouble() ?? 0.0;
    return GestureDetector(
      onTap: () => context.push('/lecturer/classes/${cls['id']}'),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cls['course_name'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${cls['course_code']} • Sem ${cls['semester']}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const Spacer(),
            Text('${cls['student_count'] ?? 0} mahasiswa', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingSubmissionCard extends StatelessWidget {
  const _PendingSubmissionCard({required this.data});
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.warning.withValues(alpha: 0.2), child: const Icon(Icons.assignment_late_rounded, color: AppColors.warning, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['student_name'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(data['task_title'] ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
