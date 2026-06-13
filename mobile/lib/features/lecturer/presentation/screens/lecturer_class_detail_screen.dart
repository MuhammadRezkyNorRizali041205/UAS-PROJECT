// lib/features/lecturer/presentation/screens/lecturer_class_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

part 'lecturer_class_detail_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> lecturerClassDetail(Ref ref, String classId) =>
    ref.read(lecturerRepositoryProvider).getClassDetail(classId);

@riverpod
Future<List<dynamic>> lecturerClassTasks(Ref ref, String classId) =>
    ref.read(lecturerRepositoryProvider).getTasks(classId);

class LecturerClassDetailScreen extends ConsumerStatefulWidget {
  const LecturerClassDetailScreen({super.key, required this.classId});
  final String classId;

  @override
  ConsumerState<LecturerClassDetailScreen> createState() => _State();
}

class _State extends ConsumerState<LecturerClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(lecturerClassDetailProvider(widget.classId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: detail.when(
          loading: () => const Text('Kelas'),
          error: (_, __) => const Text('Kelas'),
          data: (d) => Text(d['class']?['course_name'] ?? 'Kelas'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Tambah Mahasiswa',
            onPressed: () => _showEnrollDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Mahasiswa'),
            Tab(text: 'Tugas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat Tugas'),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (d) => TabBarView(
          controller: _tab,
          children: [
            _StudentsTab(classId: widget.classId, students: (d['students'] as List?) ?? []),
            _TasksTab(classId: widget.classId, ref: ref),
          ],
        ),
      ),
    );
  }

  void _showEnrollDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tambah Mahasiswa', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Email atau NIM mahasiswa',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref.read(lecturerRepositoryProvider).enrollStudent(widget.classId, ctrl.text.trim());
                ref.invalidate(lecturerClassDetailProvider(widget.classId));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mahasiswa berhasil ditambahkan')));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Buat Tugas Baru', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(titleCtrl, 'Judul Tugas'),
                const SizedBox(height: 8),
                _field(descCtrl, 'Deskripsi', maxLines: 3),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    deadline == null ? 'Pilih Deadline' : 'Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => deadline = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || deadline == null) return;
                Navigator.pop(ctx);
                try {
                  await ref.read(lecturerRepositoryProvider).createTask(widget.classId, {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'deadline': deadline!.toIso8601String(),
                  });
                  ref.invalidate(lecturerClassTasksProvider(widget.classId));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas berhasil dibuat')));
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1}) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: const TextStyle(color: AppColors.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
    ),
  );
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab({required this.classId, required this.students});
  final String classId;
  final List<dynamic> students;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const Center(child: Text('Belum ada mahasiswa', style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (_, i) {
        final s = students[i];
        final completion = (s['completion_rate'] as num?)?.toDouble() ?? 0.0;
        final isAtRisk = completion < 50;
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: isAtRisk ? AppColors.danger.withValues(alpha: 0.3) : AppColors.border),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                (s['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(s['name'] ?? '', style: const TextStyle(color: AppColors.textPrimary)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NIM: ${s['nim'] ?? '-'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: completion / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(isAtRisk ? AppColors.danger : AppColors.success),
                ),
                Text('${completion.toStringAsFixed(0)}% selesai${isAtRisk ? ' • Perlu Perhatian' : ''}',
                    style: TextStyle(color: isAtRisk ? AppColors.danger : AppColors.textMuted, fontSize: 10)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () => context.push('/lecturer/classes/$classId/students/${s['id']}/progress'),
          ),
        );
      },
    );
  }
}

class _TasksTab extends ConsumerWidget {
  const _TasksTab({required this.classId, required this.ref});
  final String classId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final tasks = widgetRef.watch(lecturerClassTasksProvider(classId));
    return tasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) => list.isEmpty
          ? const Center(child: Text('Belum ada tugas', style: TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final t = list[i];
                final deadline = DateTime.tryParse(t['deadline'] ?? '');
                final isOverdue = deadline != null && deadline.isBefore(DateTime.now());
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.assignment_rounded, color: isOverdue ? AppColors.danger : AppColors.primary),
                    title: Text(t['title'] ?? '', style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(
                      'Deadline: ${deadline != null ? '${deadline.day}/${deadline.month}/${deadline.year}' : '-'}\n'
                      '${t['submitted_count'] ?? 0}/${(t['submitted_count'] ?? 0) + (t['graded_count'] ?? 0)} dikumpulkan',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    onTap: () => context.push('/lecturer/tasks/${t['id']}/submissions'),
                  ),
                );
              },
            ),
    );
  }
}
