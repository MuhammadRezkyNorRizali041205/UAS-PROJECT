// path: lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  XFile? _pickedAvatar;
  bool _initialized = false;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nimCtrl.dispose();
    _facultyCtrl.dispose();
    _majorCtrl.dispose();
    _semesterCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (profile) {
          _bindInitial(profile);

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          children: [
                            ProfileAvatarWidget(
                              name: _nameCtrl.text.isEmpty
                                  ? profile.name
                                  : _nameCtrl.text,
                              avatarUrl: profile.avatarUrl,
                              size: 80,
                              isUploading: _uploadingAvatar,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.surface, width: 2),
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_pickedAvatar != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image_rounded,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Avatar baru: ${_pickedAvatar!.name}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _nimCtrl,
                      label: 'NIM / NIP',
                      hint: 'Opsional',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _facultyCtrl,
                      label: 'Fakultas',
                      hint: 'Opsional',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _majorCtrl,
                      label: 'Program Studi',
                      hint: 'Opsional',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _semesterCtrl,
                      label: 'Semester',
                      hint: '1 - 14',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final sem = int.tryParse(value.trim());
                        if (sem == null || sem < 1 || sem > 14) {
                          return 'Semester harus 1 - 14';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: 'No. Telepon',
                      hint: 'Opsional',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _bioCtrl,
                      label: 'Bio',
                      hint: 'Ceritakan singkat tentangmu',
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_bioCtrl.text.length}/500',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _bindInitial(dynamic profile) {
    if (_initialized) return;
    _nameCtrl.text = profile.name;
    _nimCtrl.text = profile.nim ?? '';
    _facultyCtrl.text = profile.faculty ?? '';
    _majorCtrl.text = profile.major ?? '';
    _semesterCtrl.text = profile.semester?.toString() ?? '';
    _phoneCtrl.text = profile.phone ?? '';
    _bioCtrl.text = profile.bio ?? '';
    _bioCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _initialized = true;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Pilih dari galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('Ambil dari kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _pickedAvatar = picked;
      _uploadingAvatar = true;
    });

    final err = await ref.read(profileProvider.notifier).updateAvatar(picked);
    if (!mounted) return;

    setState(() => _uploadingAvatar = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Avatar berhasil diperbarui'),
        backgroundColor: err == null ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'nim': _nimCtrl.text.trim().isEmpty ? null : _nimCtrl.text.trim(),
      'faculty':
          _facultyCtrl.text.trim().isEmpty ? null : _facultyCtrl.text.trim(),
      'major': _majorCtrl.text.trim().isEmpty ? null : _majorCtrl.text.trim(),
      'semester': _semesterCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_semesterCtrl.text.trim()),
      'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
    };

    final err = await ref.read(profileProvider.notifier).updateProfile(data);

    if (!mounted) return;
    setState(() => _saving = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }
}
