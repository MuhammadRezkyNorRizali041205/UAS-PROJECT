// lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profil')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, size: 48, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Coming in Bagian 10', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
