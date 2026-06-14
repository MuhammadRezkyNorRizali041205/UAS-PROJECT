// lib/features/lecturer/presentation/screens/lecturer_attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

part 'lecturer_attendance_screen.g.dart';

@riverpod
Future<List<dynamic>> lecturerAttendanceSessionsList(Ref ref, String classId) =>
    ref.read(lecturerRepositoryProvider).getAttendanceSessions(classId);

class LecturerAttendanceScreen extends ConsumerWidget {
  const LecturerAttendanceScreen({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(lecturerAttendanceSessionsListProvider(classId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Absensi Kelas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartDialog(context, ref),
        icon: const Icon(Icons.qr_code_rounded),
        label: const Text('Mulai Absensi'),
      ),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (list) => list.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_rounded, color: AppColors.textMuted, size: 64),
                    SizedBox(height: 16),
                    Text('Belum ada sesi absensi',
                        style: TextStyle(color: AppColors.textMuted)),
                    SizedBox(height: 8),
                    Text('Tekan tombol di bawah untuk memulai sesi baru',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(lecturerAttendanceSessionsListProvider(classId)),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _SessionCard(session: list[i]),
                ),
              ),
      ),
    );
  }

  void _showStartDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    int duration    = 90;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Mulai Sesi Absensi',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Judul Sesi',
                  hintText: 'Pertemuan 1 – Pengenalan',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('Durasi: ',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: duration,
                    dropdownColor: AppColors.surfaceElevated,
                    items: [30, 60, 90, 120, 180]
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text('$m menit',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => duration = v!),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  final now   = DateTime.now();
                  final until = now.add(Duration(minutes: duration));
                  final detail = await ref
                      .read(lecturerRepositoryProvider)
                      .createAttendanceSession(classId, {
                    'title': titleCtrl.text.trim(),
                    'valid_from': now.toIso8601String(),
                    'valid_until': until.toIso8601String(),
                  });
                  ref.invalidate(lecturerAttendanceSessionsListProvider(classId));
                  if (context.mounted) {
                    final sessionId =
                        detail['session']?['id'] as int?;
                    if (sessionId != null) {
                      context.push('/lecturer/attendance/$sessionId/qr');
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memulai sesi: $e')));
                  }
                }
              },
              child: const Text('Mulai'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final dynamic session;

  @override
  Widget build(BuildContext context) {
    final isActive     = session['is_active'] as bool? ?? false;
    final presentCount = session['present_count'] as int? ?? 0;
    final total        = session['total_students'] as int? ?? 0;
    final rate         = (session['attendance_rate'] as num?)?.toDouble() ?? 0.0;
    final startsAt     = DateTime.tryParse(session['starts_at'] as String? ?? '');
    final id           = session['id'];

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isActive
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (id != null) context.push('/lecturer/attendance/$id/qr');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      (isActive ? AppColors.success : AppColors.textMuted)
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.qr_code_rounded,
                    color: isActive ? AppColors.success : AppColors.textMuted),
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
                            session['title'] as String? ?? '',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Aktif',
                                style: TextStyle(
                                    color: AppColors.success, fontSize: 10)),
                          ),
                      ],
                    ),
                    if (startsAt != null)
                      Text(
                        '${startsAt.day}/${startsAt.month}/${startsAt.year} '
                        '${startsAt.hour.toString().padLeft(2, '0')}:'
                        '${startsAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '$presentCount/$total hadir · ${rate.toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: rate >= 75
                              ? AppColors.success
                              : rate >= 50
                                  ? AppColors.warning
                                  : AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
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
