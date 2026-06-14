// lib/features/lecturer/presentation/screens/lecturer_student_progress_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

part 'lecturer_student_progress_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> studentProgress(Ref ref, String classId, String studentId) =>
    ref.read(lecturerRepositoryProvider).getStudentProgress(classId, studentId);

class LecturerStudentProgressScreen extends ConsumerWidget {
  const LecturerStudentProgressScreen({
    super.key,
    required this.classId,
    required this.studentId,
  });
  final String classId, studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(studentProgressProvider(classId, studentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: progress.when(
          loading: () => const Text('Progres Mahasiswa'),
          error: (_, __) => const Text('Progres Mahasiswa'),
          data: (d) => Text(d['student']?['name'] ?? 'Progres'),
        ),
      ),
      body: progress.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (d) => _buildContent(context, d),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> d) {
    final student    = d['student'] as Map<String, dynamic>? ?? {};
    final tasks      = (d['tasks'] as List?) ?? [];
    final attendance = (d['attendance'] as List?) ?? [];
    final summary    = d['summary'] as Map<String, dynamic>? ?? {};

    final overallScore    = summary['overall_score'] as num?;
    final grade           = summary['grade'] as String? ?? '-';
    final attendanceRate  = (summary['attendance_rate'] as num?)?.toDouble() ?? 0.0;
    final completionRate  = (summary['completion_rate'] as num?)?.toDouble() ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  (student['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student['name'] ?? '',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text('NIM: ${student['nim'] ?? '-'}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (overallScore != null)
                Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.gradeColor(grade).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gradeColor(grade), width: 2),
                      ),
                      child: Text(grade,
                          style: TextStyle(
                              color: AppColors.gradeColor(grade),
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    const SizedBox(height: 4),
                    Text(overallScore.toStringAsFixed(1),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Summary stats
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Penyelesaian Tugas',
                value: '${completionRate.toStringAsFixed(0)}%',
                icon: Icons.assignment_turned_in_rounded,
                color: completionRate >= 75
                    ? AppColors.success
                    : completionRate >= 50
                        ? AppColors.warning
                        : AppColors.danger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Kehadiran',
                value: '${attendanceRate.toStringAsFixed(0)}%',
                icon: Icons.how_to_reg_rounded,
                color: attendanceRate >= 75
                    ? AppColors.success
                    : attendanceRate >= 50
                        ? AppColors.warning
                        : AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Tasks section
        const Text('Progres Tugas',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          const Text('Belum ada tugas', style: TextStyle(color: AppColors.textMuted))
        else
          ...tasks.map((t) => _TaskProgressCard(task: t)),
        const SizedBox(height: 20),
        // Attendance section
        const Text('Riwayat Absensi',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 12),
        if (attendance.isEmpty)
          const Text('Belum ada sesi absensi',
              style: TextStyle(color: AppColors.textMuted))
        else
          ...attendance.map((a) => _AttendanceLogCard(log: a)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
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
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TaskProgressCard extends StatelessWidget {
  const _TaskProgressCard({required this.task});
  final dynamic task;

  @override
  Widget build(BuildContext context) {
    final status   = task['status'] as String? ?? 'pending';
    final score    = task['score'] as int?;
    final grade    = task['letter_grade'] as String? ?? '-';
    final deadline = DateTime.tryParse(task['deadline'] ?? '');

    final (icon, color, label) = switch (status) {
      'graded'    => (Icons.check_circle_rounded, AppColors.success, 'Dinilai'),
      'submitted' => (Icons.upload_file_rounded, AppColors.primary, 'Dikumpulkan'),
      'late'      => (Icons.schedule_rounded, AppColors.warning, 'Terlambat'),
      _           => (Icons.radio_button_unchecked, AppColors.textMuted, 'Belum Dikumpul'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (deadline != null)
                  Text('Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(label,
                      style: TextStyle(color: color, fontSize: 11)),
                ),
              ],
            ),
          ),
          if (score != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$score',
                    style: TextStyle(
                        color: AppColors.gradeColor(grade),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text('Grade $grade',
                    style: TextStyle(
                        color: AppColors.gradeColor(grade), fontSize: 11)),
              ],
            ),
        ],
      ),
    );
  }
}

class _AttendanceLogCard extends StatelessWidget {
  const _AttendanceLogCard({required this.log});
  final dynamic log;

  @override
  Widget build(BuildContext context) {
    final status    = log['status'] as String? ?? 'absent';
    final isPresent = status == 'present';
    final date      = DateTime.tryParse(log['date'] as String? ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isPresent
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isPresent ? AppColors.success : AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              log['title'] as String? ?? '',
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isPresent ? 'Hadir' : 'Tidak Hadir',
                style: TextStyle(
                    color: isPresent ? AppColors.success : AppColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              if (date != null)
                Text('${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
