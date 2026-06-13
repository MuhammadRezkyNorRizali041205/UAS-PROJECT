// lib/features/lecturer/presentation/screens/lecturer_task_submissions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

part 'lecturer_task_submissions_screen.g.dart';

@riverpod
Future<List<dynamic>> taskSubmissions(Ref ref, String taskId, String filter) =>
    ref.read(lecturerRepositoryProvider).getSubmissions(taskId, filter: filter == 'all' ? null : filter);

class LecturerTaskSubmissionsScreen extends ConsumerStatefulWidget {
  const LecturerTaskSubmissionsScreen({super.key, required this.taskId});
  final String taskId;

  @override
  ConsumerState<LecturerTaskSubmissionsScreen> createState() => _State();
}

class _State extends ConsumerState<LecturerTaskSubmissionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final submissions = ref.watch(taskSubmissionsProvider(widget.taskId, _filter));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Daftar Pengumpulan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'submitted', 'graded', 'late', 'pending'].map((f) {
                  final labels = {
                    'all': 'Semua', 'submitted': 'Belum Dinilai',
                    'graded': 'Sudah Dinilai', 'late': 'Terlambat', 'pending': 'Belum Kumpul',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(labels[f]!),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: _filter == f ? AppColors.primary : AppColors.textMuted,
                        fontSize: 12,
                      ),
                      side: BorderSide(color: _filter == f ? AppColors.primary : AppColors.border),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: submissions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
              data: (list) => list.isEmpty
                  ? const Center(child: Text('Tidak ada data', style: TextStyle(color: AppColors.textMuted)))
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(taskSubmissionsProvider(widget.taskId, _filter)),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _SubmissionCard(
                          data: list[i],
                          taskId: widget.taskId,
                          filter: _filter,
                          onGraded: () => ref.invalidate(taskSubmissionsProvider(widget.taskId, _filter)),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.data, required this.taskId, required this.filter, required this.onGraded});
  final dynamic data;
  final String taskId, filter;
  final VoidCallback onGraded;

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'pending';
    final score  = data['score'] as int?;

    final (chipColor, chipLabel) = switch (status) {
      'graded'    => (AppColors.success, 'Dinilai'),
      'submitted' => (AppColors.primary, 'Dikumpulkan'),
      'late'      => (AppColors.warning, 'Terlambat'),
      _           => (AppColors.textMuted, 'Belum Kumpul'),
    };

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceElevated,
          child: Text(
            ((data['student']?['name'] as String?) ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(data['student']?['name'] ?? '-', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: chipColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(chipLabel, style: TextStyle(color: chipColor, fontSize: 11)),
            ),
            if (score != null) ...[
              const SizedBox(width: 8),
              Text('$score/100', style: TextStyle(color: AppColors.gradeColor(_scoreToGrade(score)), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        trailing: status == 'submitted' || status == 'late'
            ? ElevatedButton(
                onPressed: () => context.push('/lecturer/submissions/${data['submission_id']}/grade').then((_) => onGraded()),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                child: const Text('Nilai', style: TextStyle(fontSize: 12)),
              )
            : const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }

  String _scoreToGrade(int score) {
    if (score >= 85) return 'A';
    if (score >= 70) return 'B';
    if (score >= 55) return 'C';
    return 'D';
  }
}
