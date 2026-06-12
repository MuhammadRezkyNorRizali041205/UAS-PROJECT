// lib/features/attendance/presentation/screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(attendanceHistoryProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: SkeletonList(count: 6),
        ),
        error: (e, _) => ErrorState(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(attendanceHistoryProvider),
        ),
        data: (logs) => logs.isEmpty
            ? const EmptyState(
                icon: Icons.fact_check_outlined,
                title: 'Belum ada riwayat presensi',
                subtitle: 'Scan QR presensi untuk mulai merekam kehadiran.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final log = logs[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.session?.courseName ?? 'Presensi',
                                style: AppTextStyles.headingSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (log.session?.location != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 12,
                                        color: AppColors.textMuted),
                                    const SizedBox(width: 3),
                                    Text(
                                      log.session!.location!,
                                      style: AppTextStyles.labelSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                log.scannedAtFormatted.isNotEmpty
                                    ? log.scannedAtFormatted
                                    : _formatDate(log.scannedAt),
                                style: AppTextStyles.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_rounded,
                            color: AppColors.success, size: 18),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year}, $h:$m';
  }
}
