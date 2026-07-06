// lib/features/tugas_uas/presentation/screens/tugas_riwayat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'tugas_mata_kuliah_screen.dart';

part 'tugas_riwayat_screen.g.dart';

@riverpod
Future<List<dynamic>> tugasRiwayat(Ref ref) =>
    ref.read(tugasUasRepositoryProvider).getRiwayat();

class TugasRiwayatScreen extends ConsumerWidget {
  const TugasRiwayatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayat = ref.watch(tugasRiwayatProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Riwayat Tugas',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: riwayat.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, color: AppColors.textMuted, size: 56),
              const SizedBox(height: 12),
              Text('$e',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(tugasRiwayatProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 64),
                  SizedBox(height: 16),
                  Text('Belum ada tugas dikumpulkan',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tugasRiwayatProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _RiwayatCard(tugas: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  const _RiwayatCard({required this.tugas});
  final dynamic tugas;

  @override
  Widget build(BuildContext context) {
    final status = tugas['status'] as String? ?? 'dikumpulkan';
    final sudahDikumpulkan = status == 'dikumpulkan';
    final submittedAt = tugas['submitted_at'] as String?;
    String? tanggal;
    if (submittedAt != null) {
      try {
        final dt = DateTime.parse(submittedAt).toLocal();
        tanggal = '${dt.day} ${_bulan(dt.month)} ${dt.year}, ${_pad(dt.hour)}:${_pad(dt.minute)}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sudahDikumpulkan
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(tugas['nama_mk'] ?? '-',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (sudahDikumpulkan ? AppColors.success : AppColors.danger)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sudahDikumpulkan ? 'Dikumpulkan' : 'Terlambat',
                  style: TextStyle(
                    color: sudahDikumpulkan ? AppColors.success : AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(tugas['judul_project'] ?? '-',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('Dosen: ${tugas['nama_dosen'] ?? '-'}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          if (tanggal != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(tanggal,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ],
          if ((tugas['link_github'] as String?)?.isNotEmpty == true ||
              (tugas['link_youtube'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if ((tugas['link_github'] as String?)?.isNotEmpty == true)
                  _LinkChip(icon: Icons.code, label: 'GitHub'),
                if ((tugas['link_youtube'] as String?)?.isNotEmpty == true)
                  _LinkChip(icon: Icons.play_circle_outline, label: 'YouTube'),
                if ((tugas['link_gdrive'] as String?)?.isNotEmpty == true)
                  _LinkChip(icon: Icons.folder_outlined, label: 'Drive'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _bulan(int m) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][m];
  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
        ],
      ),
    );
  }
}
