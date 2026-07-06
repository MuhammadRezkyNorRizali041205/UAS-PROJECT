// lib/features/student_class/presentation/screens/student_task_submit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'student_class_list_screen.dart';

part 'student_task_submit_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> studentTaskSubmission(Ref ref, String taskId) =>
    ref.read(studentClassRepositoryProvider).getMySubmission(taskId);

// ─── Screen ───────────────────────────────────────────────────────────────────

class StudentTaskSubmitScreen extends ConsumerWidget {
  const StudentTaskSubmitScreen({super.key, required this.taskId, required this.classId});
  final String taskId, classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studentTaskSubmissionProvider(taskId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: async.when(
          loading: () => const Text('Detail Tugas'),
          error:   (_, __) => const Text('Detail Tugas'),
          data:    (d) => Text(d['task']?['title'] ?? 'Detail Tugas',
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => _ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(studentTaskSubmissionProvider(taskId)),
        ),
        data: (d) {
          final task       = d['task'] as Map<String, dynamic>? ?? {};
          final submission = d['submission'] as Map<String, dynamic>?;
          return _SubmitBody(
            task:       task,
            submission: submission,
            taskId:     taskId,
            classId:    classId,
            onSuccess: () => ref.invalidate(studentTaskSubmissionProvider(taskId)),
          );
        },
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _SubmitBody extends ConsumerStatefulWidget {
  const _SubmitBody({
    required this.task,
    required this.submission,
    required this.taskId,
    required this.classId,
    required this.onSuccess,
  });
  final Map<String, dynamic> task;
  final Map<String, dynamic>? submission;
  final String taskId, classId;
  final VoidCallback onSuccess;

  @override
  ConsumerState<_SubmitBody> createState() => _SubmitBodyState();
}

class _SubmitBodyState extends ConsumerState<_SubmitBody>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  bool _submitting = false;
  bool _showSuccess = false;
  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.submission?['content'] as String? ?? '',
    );
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successScale = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi jawaban terlebih dahulu')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(studentClassRepositoryProvider)
          .submitTask(widget.taskId, content: content);
      setState(() { _submitting = false; _showSuccess = true; });
      _successCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 1600));
      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final sub  = widget.submission;
    final canSubmit = task['can_submit'] as bool? ?? true;
    final isPast    = task['is_past']    as bool? ?? false;
    final status    = sub?['status']     as String?;
    final score     = sub?['score']      as int?;
    final grade     = sub?['letter_grade'] as String?;

    if (_showSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _successScale,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 60),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tugas Berhasil Dikumpulkan!',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              isPast ? 'Pengumpulan terlambat.' : 'Tepat waktu!',
              style: TextStyle(
                  color: isPast ? AppColors.warning : AppColors.success,
                  fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onSuccess(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Task info card ─────────────────────────────────────────────
          _TaskInfoCard(task: task),
          const SizedBox(height: 16),

          // ── Status / grade card ────────────────────────────────────────
          if (sub != null) ...[
            _SubmissionStatusCard(sub: sub, score: score, grade: grade),
            const SizedBox(height: 16),
          ],

          // ── Past deadline warning ──────────────────────────────────────
          if (isPast && canSubmit)
            const _WarningBanner(
              text: 'Deadline sudah lewat. Pengumpulan akan ditandai terlambat.',
              color: AppColors.warning,
            ),
          if (isPast && canSubmit) const SizedBox(height: 16),

          // ── Cannot submit (already graded) ─────────────────────────────
          if (!canSubmit) ...[
            _WarningBanner(
              text: status == 'graded'
                  ? 'Tugas ini sudah dinilai. Pengumpulan ulang tidak diizinkan.'
                  : 'Pengumpulan tidak tersedia.',
              color: AppColors.info,
            ),
          ] else ...[
            // ── Submit form ──────────────────────────────────────────────
            Text(
              sub != null ? 'Edit Jawaban' : 'Jawaban / Keterangan',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ctrl,
              maxLines: 10,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Tuliskan jawaban atau deskripsi pengerjaan tugas...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                contentPadding: EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.upload_file_rounded),
                label: Text(_submitting
                    ? 'Mengumpulkan...'
                    : (sub != null ? 'Kirim Ulang' : 'Kumpulkan Tugas')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Task Info Card ───────────────────────────────────────────────────────────

class _TaskInfoCard extends StatelessWidget {
  const _TaskInfoCard({required this.task});
  final Map<String, dynamic> task;

  @override
  Widget build(BuildContext context) {
    final deadline      = DateTime.tryParse(task['deadline'] ?? '');
    final timeRemaining = task['time_remaining'] as String? ?? '';
    final isPast        = task['is_past']        as bool?   ?? false;
    final maxScore      = task['max_score']      as int?    ?? 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(task['title'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$maxScore poin',
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (task['class_name'] != null) ...[
            const SizedBox(height: 6),
            Text(task['class_name'],
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
          if (task['lecturer_name'] != null) ...[
            const SizedBox(height: 2),
            Text('Dosen: ${task['lecturer_name']}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
          if (task['description'] != null && (task['description'] as String).isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.border),
            Text(task['description'],
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          ],
          const Divider(height: 20, color: AppColors.border),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  deadline != null
                      ? 'Deadline: ${deadline.day}/${deadline.month}/${deadline.year} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}'
                      : 'Deadline tidak ditentukan',
                  style: TextStyle(
                      color: isPast ? AppColors.danger : AppColors.textMuted,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          if (timeRemaining.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isPast ? Icons.timer_off_rounded : Icons.timer_outlined,
                  size: 14,
                  color: isPast ? AppColors.danger : AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  timeRemaining,
                  style: TextStyle(
                      color: isPast ? AppColors.danger : AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Submission Status Card ───────────────────────────────────────────────────

class _SubmissionStatusCard extends StatelessWidget {
  const _SubmissionStatusCard({
    required this.sub,
    required this.score,
    required this.grade,
  });
  final Map<String, dynamic> sub;
  final int? score;
  final String? grade;

  @override
  Widget build(BuildContext context) {
    final status      = sub['status']      as String? ?? '';
    final submittedAt = DateTime.tryParse(sub['submitted_at'] ?? '');
    final feedback    = sub['feedback']    as String?;

    final (color, icon, label) = switch (status) {
      'graded'    => (AppColors.success, Icons.check_circle_rounded,  'Sudah Dinilai'),
      'submitted' => (AppColors.primary, Icons.upload_file_rounded,   'Sudah Dikumpulkan'),
      'late'      => (AppColors.warning, Icons.schedule_send_rounded, 'Terlambat'),
      _           => (AppColors.textMuted, Icons.hourglass_empty_rounded, 'Menunggu'),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              if (score != null && grade != null)
                Row(
                  children: [
                    Text('$score',
                        style: TextStyle(
                            color: AppColors.gradeColor(grade ?? '-'),
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text(
                      ' / ${sub['max_score'] ?? 100}  ($grade)',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
          if (submittedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Dikumpulkan: ${submittedAt.day}/${submittedAt.month}/${submittedAt.year} ${submittedAt.hour.toString().padLeft(2, '0')}:${submittedAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
          if (feedback != null && feedback.isNotEmpty) ...[
            const Divider(height: 14, color: AppColors.border),
            const Text('Catatan Dosen:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(feedback,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

// ─── Warning Banner ───────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
