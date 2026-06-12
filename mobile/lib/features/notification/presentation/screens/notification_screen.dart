// lib/features/notification/presentation/screens/notification_screen.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifikasi')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_rounded, size: 48, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Coming in Bagian 11', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
