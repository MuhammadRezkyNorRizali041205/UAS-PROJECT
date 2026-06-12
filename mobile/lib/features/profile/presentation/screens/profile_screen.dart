// path: lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';
import '../../../../features/gamification/presentation/widgets/gamification_profile_section.dart';
import '../widgets/notification_prefs_sheet.dart';
import '../widgets/profile_avatar_widget.dart';
import '../widgets/profile_menu_item_widget.dart';
import '../widgets/profile_stat_item_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingAvatar = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(profileProvider.notifier).refreshProfile(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildHeader(context, profile),
            const SizedBox(height: 14),
            _buildStats(profile),
            const SizedBox(height: 16),
            const GamificationProfileSection(),
            const SizedBox(height: 12),
            _buildMenuSection(
              title: 'Akun',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profil',
                  onTap: () => context.push(AppRoutes.profileEdit),
                ),
                ProfileMenuItemWidget(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifikasi',
                  onTap: () =>
                      _showNotificationSheet(profile.notificationPrefs),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMenuSection(
              title: 'Sosial',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.people_outline_rounded,
                  label: 'Teman',
                  onTap: () => context.push(AppRoutes.friends),
                ),
                ProfileMenuItemWidget(
                  icon: Icons.emoji_events_outlined,
                  label: 'Feed Pencapaian',
                  onTap: () => context.push(AppRoutes.feed),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMenuSection(
              title: 'Aplikasi',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.info_outline_rounded,
                  label: 'Tentang Aplikasi',
                  onTap: () => _showAbout(context),
                ),
                ProfileMenuItemWidget(
                  icon: Icons.analytics_outlined,
                  label: 'Statistik Lengkap',
                  onTap: () => context.push(AppRoutes.analytics),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMenuSection(
              title: 'Lainnya',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.danger),
                  onTap: _showLogoutSheet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF131313)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: Stack(
              children: [
                ProfileAvatarWidget(
                  name: profile.name,
                  avatarUrl: profile.avatarUrl,
                  isUploading: _isUploadingAvatar,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                _roleBadge(profile.role),
                const SizedBox(height: 8),
                Text(
                  profile.nim?.isNotEmpty == true
                      ? profile.nim!
                      : profile.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatItemWidget(
              value: '${profile.stats.totalSchedules}',
              label: 'Jadwal',
            ),
          ),
          _vDivider(),
          Expanded(
            child: ProfileStatItemWidget(
              value: '${profile.stats.completedTasks}',
              label: 'Task Selesai',
            ),
          ),
          _vDivider(),
          Expanded(
            child: ProfileStatItemWidget(
              value: '${profile.stats.streak}',
              label: 'Streak',
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 42,
      color: AppColors.border,
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    final normalized = role.toLowerCase();
    Color color;
    String label;
    switch (normalized) {
      case 'lecturer':
      case 'dosen':
        color = const Color(0xFFF59E0B);
        label = 'Dosen';
        break;
      case 'admin':
      case 'org_admin':
        color = const Color(0xFFFF7F50);
        label = 'Admin';
        break;
      default:
        color = const Color(0xFF6366F1);
        label = 'Mahasiswa';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (file == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);
    final err = await ref.read(profileProvider.notifier).updateAvatar(file);
    if (!mounted) return;
    setState(() => _isUploadingAvatar = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Avatar berhasil diperbarui'),
        backgroundColor: err == null ? AppColors.success : AppColors.danger,
      ),
    );
  }

  void _showNotificationSheet(NotificationPrefs prefs) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (_) => NotificationPrefsSheet(prefs: prefs),
    );
  }

  Future<void> _showLogoutSheet() async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Keluar dari akun?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kamu harus login ulang untuk mengakses aplikasi.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          context.go('/login');
                        },
                        child: const Text('Keluar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Campus Assistant',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Built for better campus productivity',
    );
  }
}
