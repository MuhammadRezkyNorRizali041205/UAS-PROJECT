// lib/features/attendance/presentation/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(attendanceStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Presensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push(AppRoutes.attendanceHistory),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Stats ─────────────────────────────────────────────────
            statsState.when(
              loading: () => const SkeletonStatRow(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total',
                      value: '${stats.total}',
                      icon: Icons.fact_check_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Bulan ini',
                      value: '${stats.thisMonth}',
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Minggu ini',
                      value: '${stats.thisWeek}',
                      icon: Icons.today_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ─── Action cards ───────────────────────────────────────────
            Text('Aksi Presensi', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),

            _ActionCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan QR Presensi',
              subtitle: 'Scan kode QR yang ditampilkan dosen',
              color: AppColors.primary,
              onTap: () => context.push(AppRoutes.attendanceScan),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.qr_code_2_rounded,
              title: 'Buat Sesi Presensi',
              subtitle: 'Tampilkan QR untuk mahasiswa (dosen/panitia)',
              color: AppColors.success,
              onTap: () => context.push(AppRoutes.attendanceGenerate),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.history_rounded,
              title: 'Riwayat Presensi',
              subtitle: 'Lihat rekap kehadiran kamu',
              color: AppColors.info,
              onTap: () => context.push(AppRoutes.attendanceHistory),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.textPrimary)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headingSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      );
}
