// lib/features/lecturer/presentation/screens/lecturer_qr_display_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

class LecturerQrDisplayScreen extends ConsumerStatefulWidget {
  const LecturerQrDisplayScreen({super.key, required this.sessionId});
  final int sessionId;

  @override
  ConsumerState<LecturerQrDisplayScreen> createState() => _State();
}

class _State extends ConsumerState<LecturerQrDisplayScreen> {
  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _fetch();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _fetch());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final detail = await ref
          .read(lecturerRepositoryProvider)
          .getAttendanceDetail(widget.sessionId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _loading = false;
          _error   = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = '$e'; });
    }
  }

  Future<void> _closeSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tutup Sesi',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Tutup sesi absensi? Mahasiswa tidak bisa melakukan scan setelah ditutup.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Tutup Sesi'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _closing = true);
    try {
      await ref
          .read(lecturerRepositoryProvider)
          .closeAttendanceSession(widget.sessionId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _closing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: Center(
            child: Text(_error!,
                style: const TextStyle(color: AppColors.danger))),
      );
    }

    final session      = _detail!['session'] as Map<String, dynamic>;
    final present      = (_detail!['present'] as List?) ?? [];
    final absent       = (_detail!['absent'] as List?) ?? [];
    final presentCount = _detail!['present_count'] as int? ?? 0;
    final total        = _detail!['total_students'] as int? ?? 0;
    final isActive     = session['is_active'] as bool? ?? false;
    final minutesLeft  = session['minutes_left'] as int? ?? 0;
    final qrToken      = session['qr_token'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(session['title'] as String? ?? 'Sesi Absensi'),
        actions: [
          if (isActive)
            TextButton(
              onPressed: _closing ? null : _closeSession,
              child: _closing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Tutup Sesi',
                      style: TextStyle(color: AppColors.danger)),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // QR section
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  // Status badge
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle,
                              color: AppColors.success, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            'Aktif · $minutesLeft menit tersisa',
                            style: const TextStyle(
                                color: AppColors.success, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Sesi Ditutup',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ),
                  const SizedBox(height: 12),
                  // QR code
                  if (qrToken.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: qrToken,
                        version: QrVersions.auto,
                        size: 180,
                      ),
                    ),
                  const SizedBox(height: 14),
                  // Counters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Counter(
                          label: 'Hadir',
                          value: '$presentCount',
                          color: AppColors.success),
                      const SizedBox(width: 32),
                      _Counter(
                          label: 'Belum Hadir',
                          value: '${absent.length}',
                          color: AppColors.danger),
                      const SizedBox(width: 32),
                      _Counter(
                          label: 'Total',
                          value: '$total',
                          color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Hadir'),
                Tab(text: 'Belum Hadir'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _StudentList(students: present, isPresent: true),
                  _StudentList(students: absent, isPresent: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _StudentList extends StatelessWidget {
  const _StudentList({required this.students, required this.isPresent});
  final List<dynamic> students;
  final bool isPresent;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Text(
          isPresent ? 'Belum ada yang hadir' : 'Semua mahasiswa sudah hadir!',
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: students.length,
      itemBuilder: (_, i) {
        final s = students[i];
        // present entry: {student: {name, nim}, scanned_at}
        // absent entry:  {id, name, nim}
        final student =
            isPresent ? (s['student'] as Map<String, dynamic>? ?? s) : s;
        final scannedAt = isPresent
            ? s['scanned_at'] as String?
            : null;

        final color = isPresent ? AppColors.success : AppColors.danger;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  ((student['name'] as String?) ?? '?')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student['name'] ?? '-',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    Text('NIM: ${student['nim'] ?? '-'}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (scannedAt != null)
                Text(
                  _fmtTime(scannedAt),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }

  String _fmtTime(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
