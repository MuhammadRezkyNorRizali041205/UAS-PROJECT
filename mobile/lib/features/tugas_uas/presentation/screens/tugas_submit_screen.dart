// lib/features/tugas_uas/presentation/screens/tugas_submit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import 'tugas_mata_kuliah_screen.dart';

class TugasSubmitScreen extends ConsumerStatefulWidget {
  final int kelasMataKuliahId;
  final String namaMk;
  final String namaDosen;
  final bool sudahDikumpulkan;

  const TugasSubmitScreen({
    super.key,
    required this.kelasMataKuliahId,
    required this.namaMk,
    required this.namaDosen,
    required this.sudahDikumpulkan,
  });

  @override
  ConsumerState<TugasSubmitScreen> createState() => _TugasSubmitScreenState();
}

class _TugasSubmitScreenState extends ConsumerState<TugasSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _gdriveController = TextEditingController();
  final _githubController = TextEditingController();
  final _youtubeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _judulController.dispose();
    _gdriveController.dispose();
    _githubController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final repo = ref.read(tugasUasRepositoryProvider);
      await repo.submitTugas(
        kelasMataKuliahId: widget.kelasMataKuliahId,
        judulProject: _judulController.text.trim(),
        linkGdrive: _gdriveController.text.trim(),
        linkGithub: _githubController.text.trim(),
        linkYoutube: _youtubeController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil dikumpulkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          widget.sudahDikumpulkan ? 'Perbarui Tugas' : 'Kumpulkan Tugas',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info mata kuliah
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mata Kuliah',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(widget.namaMk,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Dosen: ${widget.namaDosen}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _sectionLabel('Judul Project / Aplikasi *'),
              _buildTextField(
                controller: _judulController,
                hint: 'Contoh: Aplikasi E-Commerce Toko Baju Poliban',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _sectionLabel('Tautan Pendukung (Opsional)'),
              const SizedBox(height: 4),
              _buildTextField(
                controller: _gdriveController,
                hint: 'https://drive.google.com/...',
                label: 'Link Google Drive',
                validator: _urlValidator,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _githubController,
                hint: 'https://github.com/username/repo-name',
                label: 'Link Repository GitHub',
                validator: _urlValidator,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _youtubeController,
                hint: 'https://youtube.com/watch?v=...',
                label: 'Link Video Demo YouTube',
                validator: _urlValidator,
              ),
              const SizedBox(height: 8),
              const Text(
                '* File database (.sql) dan laporan (.docx) dapat diunggah melalui Google Drive',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          widget.sudahDikumpulkan ? 'Perbarui Tugas' : 'Kumpulkan Tugas',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(label,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  String? _urlValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final uri = Uri.tryParse(v.trim());
    if (uri == null || !uri.isAbsolute) return 'URL tidak valid';
    return null;
  }
}
