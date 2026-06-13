// lib/features/lecturer/presentation/screens/lecturer_grade_submission_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

class LecturerGradeSubmissionScreen extends ConsumerStatefulWidget {
  const LecturerGradeSubmissionScreen({super.key, required this.submissionId});
  final String submissionId;

  @override
  ConsumerState<LecturerGradeSubmissionScreen> createState() => _State();
}

class _State extends ConsumerState<LecturerGradeSubmissionScreen> {
  int _score = 80;
  final _feedbackCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Nilai Tugas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ID Pengumpulan', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(widget.submissionId,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Nilai (0 – 100)',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _score.toDouble(),
                    min: 0, max: 100, divisions: 100,
                    activeColor: AppColors.gradeColor(_grade(_score)),
                    onChanged: (v) => setState(() => _score = v.round()),
                  ),
                ),
                Container(
                  width: 52,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gradeColor(_grade(_score)).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_score',
                      style: TextStyle(
                        color: AppColors.gradeColor(_grade(_score)),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                ),
              ],
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gradeColor(_grade(_score)).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Grade: ${_grade(_score)} — ${_desc(_score)}',
                  style: TextStyle(color: AppColors.gradeColor(_grade(_score)), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Feedback (opsional)',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackCtrl,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Tulis catatan untuk mahasiswa...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan Nilai'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(lecturerRepositoryProvider).gradeSubmission(
        widget.submissionId, _score, _feedbackCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nilai berhasil disimpan')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _grade(int s) {
    if (s >= 85) return 'A';
    if (s >= 70) return 'B';
    if (s >= 55) return 'C';
    if (s >= 40) return 'D';
    return 'E';
  }

  String _desc(int s) {
    if (s >= 85) return 'Sangat Baik';
    if (s >= 70) return 'Baik';
    if (s >= 55) return 'Cukup';
    if (s >= 40) return 'Kurang';
    return 'Sangat Kurang';
  }
}
