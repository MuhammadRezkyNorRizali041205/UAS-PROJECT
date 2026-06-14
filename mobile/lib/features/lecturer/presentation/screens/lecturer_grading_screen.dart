// lib/features/lecturer/presentation/screens/lecturer_grading_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'lecturer_dashboard_screen.dart';

part 'lecturer_grading_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> allPendingGrading(Ref ref) =>
    ref.read(lecturerRepositoryProvider).getAllPendingGrading();

class LecturerGradingScreen extends ConsumerWidget {
  const LecturerGradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grading = ref.watch(allPendingGradingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: grading.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$e', style: const TextStyle(color: AppColors.danger)),
              TextButton(
                onPressed: () => ref.invalidate(allPendingGradingProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          )),
          data: (data) {
            final submissions = (data['submissions'] as List?) ?? [];
            final total       = data['total'] as int? ?? 0;

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(allPendingGradingProvider),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.surface,
                    pinned: true,
                    title: const Text('Penilaian'),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(40),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: total > 0
                                    ? AppColors.warning.withValues(alpha: 0.15)
                                    : AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                total == 0
                                    ? 'Semua sudah dinilai'
                                    : '$total tugas menunggu penilaian',
                                style: TextStyle(
                                  color: total > 0
                                      ? AppColors.warning
                                      : AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (submissions.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: AppColors.success, size: 72),
                            SizedBox(height: 16),
                            Text('Semua tugas sudah dinilai!',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Tidak ada yang menunggu penilaian',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.separated(
                        itemCount: submissions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _PendingCard(
                          data: submissions[i],
                          onGraded: () =>
                              ref.invalidate(allPendingGradingProvider),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.data, required this.onGraded});
  final dynamic data;
  final VoidCallback onGraded;

  @override
  Widget build(BuildContext context) {
    final student     = data['student'] as Map<String, dynamic>? ?? {};
    final task        = data['task'] as Map<String, dynamic>? ?? {};
    final cls         = data['class'] as Map<String, dynamic>? ?? {};
    final isLate      = data['is_late'] as bool? ?? false;
    final submittedAt =
        DateTime.tryParse(data['submitted_at'] as String? ?? '');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isLate
                ? AppColors.warning.withValues(alpha: 0.4)
                : AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              ((student['name'] as String?) ?? '?')
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'] as String? ?? '-',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
                Text(task['title'] as String? ?? '-',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Flexible(
                      child: Text(cls['name'] as String? ?? '-',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (isLate) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Terlambat',
                            style: TextStyle(
                                color: AppColors.warning, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                if (submittedAt != null)
                  Text(
                    'Dikumpul: ${submittedAt.day}/${submittedAt.month}/${submittedAt.year}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () =>
                context
                    .push('/lecturer/submissions/${data['submission_id']}/grade')
                    .then((_) => onGraded()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Nilai', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
