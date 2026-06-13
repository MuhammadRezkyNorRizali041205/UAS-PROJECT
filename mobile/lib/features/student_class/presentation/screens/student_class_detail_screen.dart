// lib/features/student_class/presentation/screens/student_class_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'student_class_list_screen.dart';

part 'student_class_detail_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> studentClassDetail(Ref ref, String classId) =>
    ref.read(studentClassRepositoryProvider).getClassDetail(classId);

class StudentClassDetailScreen extends ConsumerWidget {
  const StudentClassDetailScreen({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(studentClassDetailProvider(classId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: detail.when(
          loading: () => const Text('Kelas'),
          error: (_, __) => const Text('Kelas'),
          data: (d) => Text(d['class']?['course_name'] ?? 'Kelas'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (d) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(studentClassDetailProvider(classId)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildClassInfo(d['class'] as Map<String, dynamic>? ?? {}),
              const SizedBox(height: 20),
              const Text('Daftar Tugas',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...((d['tasks'] as List?) ?? []).map((t) => _TaskCard(task: t, classId: classId)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassInfo(Map<String, dynamic> cls) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cls['course_name'] ?? '',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('${cls['course_code']} • Semester ${cls['semester']} • ${cls['academic_year']}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Dosen: ${cls['lecturer_name'] ?? '-'}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (cls['description'] != null && (cls['description'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(cls['description'], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.classId});
  final dynamic task;
  final String classId;

  @override
  Widget build(BuildContext context) {
    final status   = task['status'] as String? ?? 'pending';
    final deadline = DateTime.tryParse(task['deadline'] ?? '');
    final isOverdue = deadline != null && deadline.isBefore(DateTime.now()) && status == 'pending';
    final submission = task['submission'] as Map<String, dynamic>?;
    final score = submission?['score'] as int?;

    final (color, icon, label) = switch (status) {
      'graded'    => (AppColors.success, Icons.check_circle_rounded,       'Dinilai'),
      'submitted' => (AppColors.primary, Icons.upload_file_rounded,        'Dikumpulkan'),
      'late'      => (AppColors.warning, Icons.schedule_send_rounded,      'Terlambat'),
      _           => isOverdue
          ? (AppColors.danger,  Icons.warning_amber_rounded,  'Melewati Deadline')
          : (AppColors.textMuted, Icons.assignment_outlined,  'Belum Dikumpul'),
    };

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isOverdue && status == 'pending' ? AppColors.danger.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/student/class-tasks/${task['id']}/submit?classId=$classId'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task['title'] ?? '',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                    if (deadline != null)
                      Text('Deadline: ${deadline.day}/${deadline.month}/${deadline.year} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: isOverdue ? AppColors.danger : AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              if (score != null)
                Column(
                  children: [
                    Text('$score', style: TextStyle(
                      color: AppColors.gradeColor(submission?['letter_grade'] ?? '-'),
                      fontWeight: FontWeight.bold, fontSize: 20,
                    )),
                    Text('/ ${task['max_score'] ?? 100}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
