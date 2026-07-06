// lib/features/tugas_uas/presentation/screens/tugas_profil_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import 'tugas_mata_kuliah_screen.dart';

part 'tugas_profil_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> tugasProfil(Ref ref) =>
    ref.read(tugasUasRepositoryProvider).getProfil();

class TugasProfilScreen extends ConsumerWidget {
  const TugasProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profil = ref.watch(tugasProfilProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Profil Saya',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Keluar', style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text('Yakin ingin keluar?',
                      style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authProvider.notifier).logout();
                      },
                      child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger, fontSize: 13)),
          ),
        ],
      ),
      body: profil.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, color: AppColors.textMuted, size: 56),
              const SizedBox(height: 12),
              Text('$e',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(tugasProfilProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (p) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                ),
                child: Center(
                  child: Text(
                    (p['name'] as String? ?? '?').isNotEmpty
                        ? (p['name'] as String).substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(p['name'] ?? '-',
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(p['nim'] ?? '-',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
              if ((p['nama_prodi'] as String?)?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.roleStudent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('MAHASISWA AKTIF',
                      style: const TextStyle(
                          color: AppColors.roleStudent, fontSize: 11, fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
              ],
              const SizedBox(height: 24),

              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Akademik & Kontak',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    _InfoRow(icon: Icons.school_outlined, label: 'Program Studi',
                        value: p['nama_prodi'] ?? '-'),
                    const Divider(color: AppColors.border, height: 20),
                    _InfoRow(icon: Icons.class_outlined, label: 'Kelas',
                        value: p['nama_kelas'] ?? '-'),
                    const Divider(color: AppColors.border, height: 20),
                    _InfoRow(icon: Icons.email_outlined, label: 'Email',
                        value: p['email'] ?? '-'),
                    if ((p['no_hp'] as String?)?.isNotEmpty == true) ...[
                      const Divider(color: AppColors.border, height: 20),
                      _InfoRow(icon: Icons.phone_outlined, label: 'No. HP',
                          value: p['no_hp'] ?? '-'),
                    ],
                    if ((p['tahun_akademik'] as String?)?.isNotEmpty == true) ...[
                      const Divider(color: AppColors.border, height: 20),
                      _InfoRow(icon: Icons.calendar_today_outlined, label: 'Tahun Akademik',
                          value: p['tahun_akademik'] ?? '-'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
