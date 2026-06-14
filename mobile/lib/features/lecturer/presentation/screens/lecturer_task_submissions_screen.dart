// lib/features/lecturer/presentation/screens/lecturer_task_submissions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

part 'lecturer_task_submissions_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> taskSubmissions(Ref ref, String taskId, String filter) =>
    ref.read(lecturerRepositoryProvider).getSubmissions(
          taskId,
          filter: filter == 'all' ? null : filter,
        );

class LecturerTaskSubmissionsScreen extends ConsumerStatefulWidget {
  const LecturerTaskSubmissionsScreen({super.key, required this.taskId});
  final String taskId;

  @override
  ConsumerState<LecturerTaskSubmissionsScreen> createState() => _State();
}

class _State extends ConsumerState<LecturerTaskSubmissionsScreen> {
  String _filter = 'all';

  static const _filters = [
    ('all',      'Semua'),
    ('ungraded', 'Belum Dinilai'),
    ('graded',   'Sudah Dinilai'),
    ('late',     'Terlambat'),
    ('pending',  'Belum Kumpul'),
  ];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(taskSubmissionsProvider(widget.taskId, _filter));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Daftar Pengumpulan'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _filter == f.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f.$2),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = f.$1),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textMuted,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                          color: selected ? AppColors.primary : AppColors.border),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Summary bar
          async.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (data) {
              final summary = data['summary'] as Map<String, dynamic>? ?? {};
              return _SummaryBar(summary: summary);
            },
          ),
          // List
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('$e',
                      style: const TextStyle(color: AppColors.danger))),
              data: (data) {
                final list =
                    (data['submissions'] as List?) ?? [];
                if (list.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada data',
                          style: TextStyle(color: AppColors.textMuted)));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref
                      .invalidate(taskSubmissionsProvider(widget.taskId, _filter)),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _SubmissionCard(
                      data: list[i],
                      onGraded: () => ref.invalidate(
                          taskSubmissionsProvider(widget.taskId, _filter)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summary});
  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final total        = summary['total'] as int? ?? 0;
    final submitted    = summary['submitted'] as int? ?? 0;
    final graded       = summary['graded'] as int? ?? 0;
    final late         = summary['late'] as int? ?? 0;
    final notSubmitted = summary['not_submitted'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: 'Total', value: '$total', color: AppColors.primary),
          _SummaryItem(label: 'Perlu Dinilai', value: '$submitted', color: AppColors.warning),
          _SummaryItem(label: 'Dinilai', value: '$graded', color: AppColors.success),
          _SummaryItem(label: 'Terlambat', value: '$late', color: AppColors.info),
          _SummaryItem(label: 'Belum', value: '$notSubmitted', color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.data, required this.onGraded});
  final dynamic data;
  final VoidCallback onGraded;

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'pending';
    final score  = data['score'] as int?;
    final isLate = data['is_late'] as bool? ?? false;

    final (chipColor, chipLabel) = switch (status) {
      'graded'    => (AppColors.success, 'Dinilai'),
      'submitted' => (AppColors.primary, 'Dikumpulkan'),
      'late'      => (AppColors.warning, 'Terlambat'),
      _           => (AppColors.textMuted, 'Belum Kumpul'),
    };

    final grade = score != null ? _grade(score) : null;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: isLate && status != 'graded'
                ? AppColors.warning.withValues(alpha: 0.3)
                : AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceElevated,
          child: Text(
            ((data['student']?['name'] as String?) ?? '?')
                .substring(0, 1)
                .toUpperCase(),
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(data['student']?['name'] ?? '-',
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(chipLabel,
                  style: TextStyle(color: chipColor, fontSize: 11)),
            ),
            if (score != null && grade != null) ...[
              const SizedBox(width: 8),
              Text('$score/100',
                  style: TextStyle(
                      color: AppColors.gradeColor(grade),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        trailing: status == 'submitted' || status == 'late'
            ? ElevatedButton(
                onPressed: () =>
                    context.push('/lecturer/submissions/${data['submission_id']}/grade')
                        .then((_) => onGraded()),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                child: const Text('Nilai', style: TextStyle(fontSize: 12)),
              )
            : const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }

  String _grade(int score) {
    if (score >= 85) return 'A';
    if (score >= 70) return 'B';
    if (score >= 55) return 'C';
    if (score >= 40) return 'D';
    return 'E';
  }
}
