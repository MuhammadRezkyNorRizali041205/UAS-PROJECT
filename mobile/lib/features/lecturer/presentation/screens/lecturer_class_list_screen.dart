// lib/features/lecturer/presentation/screens/lecturer_class_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

class LecturerClassListScreen extends ConsumerWidget {
  const LecturerClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(lecturerClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Kelas Saya'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateClassDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Buat Kelas'),
      ),
      body: classes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
              const SizedBox(height: 12),
              Text('$e', style: const TextStyle(color: AppColors.textMuted)),
              TextButton(onPressed: () => ref.invalidate(lecturerClassesProvider), child: const Text('Coba Lagi')),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Belum ada kelas', style: TextStyle(color: AppColors.textMuted)))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(lecturerClassesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _ClassListTile(cls: list[i]),
                ),
              ),
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl   = TextEditingController();
    final courseCtrl = TextEditingController();
    final codeCtrl   = TextEditingController();
    final yearCtrl   = TextEditingController(text: '2025/2026');
    int semester = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Buat Kelas Baru', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _dialogField(nameCtrl, 'Nama Kelas', 'Kelas A Pemrograman Bergerak'),
                const SizedBox(height: 8),
                _dialogField(courseCtrl, 'Nama Mata Kuliah', 'Pemrograman Bergerak'),
                const SizedBox(height: 8),
                _dialogField(codeCtrl, 'Kode MK', 'CS401'),
                const SizedBox(height: 8),
                _dialogField(yearCtrl, 'Tahun Ajaran', '2025/2026'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Semester: ', style: TextStyle(color: AppColors.textSecondary)),
                    DropdownButton<int>(
                      value: semester,
                      dropdownColor: AppColors.surfaceElevated,
                      items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}', style: const TextStyle(color: AppColors.textPrimary)))),
                      onChanged: (v) => setState(() => semester = v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || courseCtrl.text.isEmpty || codeCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await ref.read(lecturerRepositoryProvider).createClass({
                    'name': nameCtrl.text.trim(),
                    'course_name': courseCtrl.text.trim(),
                    'course_code': codeCtrl.text.trim().toUpperCase(),
                    'academic_year': yearCtrl.text.trim(),
                    'semester': semester,
                  });
                  ref.invalidate(lecturerClassesProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  }
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

class _ClassListTile extends StatelessWidget {
  const _ClassListTile({required this.cls});
  final dynamic cls;

  @override
  Widget build(BuildContext context) {
    final pending = cls['pending_submissions_count'] as int? ?? 0;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded, color: AppColors.primary),
        ),
        title: Text(cls['course_name'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${cls['course_code']} • Sem ${cls['semester']} • ${cls['student_count'] ?? 0} mhs',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        trailing: pending > 0
            ? Badge(label: Text('$pending'), child: const Icon(Icons.assignment_rounded, color: AppColors.warning))
            : const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => context.push('/lecturer/classes/${cls['id']}'),
      ),
    );
  }
}
