// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded, size: 48, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Coming in Bagian 10', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
