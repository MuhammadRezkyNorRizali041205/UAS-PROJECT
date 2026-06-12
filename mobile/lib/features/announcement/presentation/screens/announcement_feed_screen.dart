// lib/features/announcement/presentation/screens/announcement_feed_screen.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  const AnnouncementFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengumuman')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_rounded, size: 48, color: AppColors.warning),
            SizedBox(height: 16),
            Text('Pengumuman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Coming in Bagian 9', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
