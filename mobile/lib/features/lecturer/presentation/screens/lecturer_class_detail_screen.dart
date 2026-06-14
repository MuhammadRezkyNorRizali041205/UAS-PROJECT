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

@riverpod
Future<List<dynamic>> lecturerStudentsWithRisk(Ref ref, String classId) =>
    ref.read(lecturerRepositoryProvider).getStudentsWithRisk(classId);

class LecturerClassDetailScreen extends ConsumerStatefulWidget {
  const LecturerClassDetailScreen({super.key, required this.classId});
  final String classId;

  @override
  ConsumerState<LecturerClassDetailScreen> createState() => _State();
}

class _State extends ConsumerState<LecturerClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (_tabIndex != _tab.index) setState(() => _tabIndex = _tab.index);
    });
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
            Tab(text: 'Absensi'),
          ],
        ),
      ),
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateTaskDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Buat Tugas'),
            )
          : _tabIndex == 2
              ? FloatingActionButton.extended(
                  onPressed: () => context.push(
                      '/lecturer/classes/${widget.classId}/attendance-mgmt'),
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text('Kelola Absensi'),
                )
              : null,
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (d) => TabBarView(
          controller: _tab,
          children: [
            _StudentsTab(classId: widget.classId),
            _TasksTab(classId: widget.classId),
            _AttendanceTab(
              classId: widget.classId,
              sessions: (d['attendance_sessions'] as List?) ?? [],
            ),
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
        title: const Text('Tambah Mahasiswa',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Email atau NIM mahasiswa',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref
                    .read(lecturerRepositoryProvider)
                    .enrollStudent(widget.classId, ctrl.text.trim());
                ref.invalidate(lecturerStudentsWithRiskProvider(widget.classId));
                ref.invalidate(lecturerClassDetailProvider(widget.classId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mahasiswa berhasil ditambahkan')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Gagal: $e')));
                }
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
    final descCtrl = TextEditingController();
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Buat Tugas Baru',
              style: TextStyle(color: AppColors.textPrimary)),
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
                    deadline == null
                        ? 'Pilih Deadline'
                        : 'Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}',
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
                  await ref.read(lecturerRepositoryProvider).createTask(
                    widget.classId,
                    {
                      'title': titleCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'deadline': deadline!.toIso8601String(),
                    },
                  );
                  ref.invalidate(lecturerClassTasksProvider(widget.classId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tugas berhasil dibuat')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Gagal: $e')));
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

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          enabledBorder:
              const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
          focusedBorder:
              const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
        ),
      );
}

// ─── Students Tab ─────────────────────────────────────────────────────────────

class _StudentsTab extends ConsumerWidget {
  const _StudentsTab({required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(lecturerStudentsWithRiskProvider(classId));

    return students.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$e', style: const TextStyle(color: AppColors.danger)),
            TextButton(
              onPressed: () => ref.invalidate(lecturerStudentsWithRiskProvider(classId)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
      data: (list) => list.isEmpty
          ? const Center(
              child: Text('Belum ada mahasiswa',
                  style: TextStyle(color: AppColors.textMuted)))
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(lecturerStudentsWithRiskProvider(classId)),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _StudentRiskCard(student: list[i], classId: classId),
              ),
            ),
    );
  }
}

class _StudentRiskCard extends StatelessWidget {
  const _StudentRiskCard({required this.student, required this.classId});
  final dynamic student;
  final String classId;

  @override
  Widget build(BuildContext context) {
    final risk = student['risk_level'] as String? ?? 'good';
    final (riskColor, riskLabel, riskIcon) = switch (risk) {
      'at_risk' => (AppColors.danger, 'Berisiko', Icons.warning_rounded),
      'warning'  => (AppColors.warning, 'Perhatian', Icons.info_outline_rounded),
      _          => (AppColors.success, 'Baik', Icons.check_circle_outline_rounded),
    };
    final completion = (student['completion_rate'] as num?)?.toDouble() ?? 0.0;
    final attendance = (student['attendance_rate'] as num?)?.toDouble() ?? 0.0;
    final avgScore   = (student['average_score'] as num?)?.toDouble() ?? 0.0;
    final grade      = student['grade'] as String? ?? 'N/A';

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
            '/lecturer/classes/$classId/students/${student['id']}/progress'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      ((student['name'] as String?) ?? '?')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student['name'] ?? '',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(riskIcon, color: riskColor, size: 11),
                              const SizedBox(width: 4),
                              Text(riskLabel,
                                  style:
                                      TextStyle(color: riskColor, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('NIM: ${student['nim'] ?? '-'}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MiniStat(
                            label: 'Tugas',
                            value: '${completion.toStringAsFixed(0)}%',
                            color: completion >= 75
                                ? AppColors.success
                                : completion >= 50
                                    ? AppColors.warning
                                    : AppColors.danger),
                        const SizedBox(width: 12),
                        _MiniStat(
                            label: 'Hadir',
                            value: '${attendance.toStringAsFixed(0)}%',
                            color: attendance >= 75
                                ? AppColors.success
                                : attendance >= 50
                                    ? AppColors.warning
                                    : AppColors.danger),
                        const SizedBox(width: 12),
                        _MiniStat(
                            label: 'Nilai',
                            value: avgScore > 0 ? '$grade (${avgScore.toStringAsFixed(0)})' : '-',
                            color: AppColors.gradeColor(grade)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

// ─── Tasks Tab ─────────────────────────────────────────────────────────────────

class _TasksTab extends ConsumerWidget {
  const _TasksTab({required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(lecturerClassTasksProvider(classId));
    return tasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (list) => list.isEmpty
          ? const Center(
              child: Text('Belum ada tugas',
                  style: TextStyle(color: AppColors.textMuted)))
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(lecturerClassTasksProvider(classId)),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final t = list[i];
                  final deadline = DateTime.tryParse(t['deadline'] ?? '');
                  final isOverdue = deadline != null && deadline.isBefore(DateTime.now());
                  final submitted = t['submitted_count'] as int? ?? 0;
                  final graded   = t['graded_count'] as int? ?? 0;
                  final pending  = t['pending_count'] as int? ?? 0;
                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment_rounded,
                        color: isOverdue ? AppColors.danger : AppColors.primary,
                      ),
                      title: Text(t['title'] ?? '',
                          style: const TextStyle(
                              color: AppColors.textPrimary)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deadline: ${deadline != null ? '${deadline.day}/${deadline.month}/${deadline.year}' : '-'}',
                            style: TextStyle(
                                color: isOverdue ? AppColors.danger : AppColors.textMuted,
                                fontSize: 11),
                          ),
                          Row(
                            children: [
                              if (pending > 0) ...[
                                Container(
                                  margin: const EdgeInsets.only(top: 4, right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('$pending perlu dinilai',
                                      style: const TextStyle(color: AppColors.warning, fontSize: 10)),
                                ),
                              ],
                              Text('$graded dinilai · $submitted dikumpulkan',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      onTap: () => context.push('/lecturer/tasks/${t['id']}/submissions'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ─── Attendance Tab ────────────────────────────────────────────────────────────

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({required this.classId, required this.sessions});
  final String classId;
  final List<dynamic> sessions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: () =>
              context.push('/lecturer/classes/$classId/attendance-mgmt'),
          icon: const Icon(Icons.qr_code_rounded),
          label: const Text('Kelola & Mulai Absensi'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Belum ada sesi absensi',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
          )
        else ...[
          Text('Sesi Terakhir (${sessions.length})',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          ...sessions.map((s) => _AttendanceSessionTile(session: s)),
        ],
      ],
    );
  }
}

class _AttendanceSessionTile extends StatelessWidget {
  const _AttendanceSessionTile({required this.session});
  final dynamic session;

  @override
  Widget build(BuildContext context) {
    final isActive = session['is_active'] as bool? ?? false;
    final present  = session['present_count'] as int? ?? 0;
    final startsAt = DateTime.tryParse(session['starts_at'] as String? ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isActive
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_2_rounded,
              color: isActive ? AppColors.success : AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session['title'] as String? ?? '',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (startsAt != null)
                  Text(
                    '${startsAt.day}/${startsAt.month}/${startsAt.year} · $present hadir',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Aktif',
                  style: TextStyle(color: AppColors.success, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
