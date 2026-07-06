// lib/features/tugas_uas/presentation/screens/tugas_mata_kuliah_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/tugas_repository.dart';

part 'tugas_mata_kuliah_screen.g.dart';

@riverpod
TugasUasRepository tugasUasRepository(Ref ref) =>
    TugasUasRepository(ref.read(dioClientProvider));

@riverpod
Future<List<dynamic>> mataKuliahSaya(Ref ref) =>
    ref.read(tugasUasRepositoryProvider).getMataKuliahSaya();

class TugasMataKuliahScreen extends ConsumerWidget {
  const TugasMataKuliahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mataKuliah = ref.watch(mataKuliahSayaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mata Kuliah Saya',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: mataKuliah.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book_outlined, color: AppColors.textMuted, size: 56),
              const SizedBox(height: 12),
              Text('$e',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(mataKuliahSayaProvider),
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
                  Icon(Icons.book_outlined, color: AppColors.textMuted, size: 64),
                  SizedBox(height: 16),
                  Text('Belum ada mata kuliah', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  SizedBox(height: 8),
                  Text('Hubungi admin untuk didaftarkan ke kelas',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mataKuliahSayaProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _MataKuliahCard(mk: list[i], ref: ref),
            ),
          );
        },
      ),
    );
  }
}

class _MataKuliahCard extends StatelessWidget {
  const _MataKuliahCard({required this.mk, required this.ref});
  final dynamic mk;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final sudah = mk['sudah_dikumpulkan'] == true;
    final kmkId = mk['kelas_mata_kuliah_id'];
    final namaMk = mk['nama_mk'] as String? ?? '-';
    final namaDosen = mk['nama_dosen'] as String? ?? '-';
    final kodeMk = mk['kode_mk'] as String? ?? '';
    final sks = mk['sks'];
    final tahunAkademik = mk['tahun_akademik'] as String? ?? '';
    final judulProject = mk['judul_project'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sudah ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaMk,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('$kodeMk • $sks SKS',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                if (sudah)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                    ),
                    child: const Text('Sudah Dikumpulkan',
                        style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Dosen: $namaDosen',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text('TA: $tahunAkademik',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            if (sudah && judulProject != null) ...[
              const SizedBox(height: 6),
              Text('Project: $judulProject',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await context.push('/tugas-uas/submit', extra: {
                    'kelas_mata_kuliah_id': kmkId,
                    'nama_mk': namaMk,
                    'nama_dosen': namaDosen,
                    'sudah': sudah,
                  });
                  ref.invalidate(mataKuliahSayaProvider);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: sudah ? AppColors.success : AppColors.primary,
                  side: BorderSide(
                    color: (sudah ? AppColors.success : AppColors.primary).withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  sudah ? 'Perbarui Tugas' : 'Kumpulkan Tugas →',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
