// lib/features/announcement/presentation/screens/announcement_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final String id;

  const AnnouncementDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.campaign_rounded, size: 48, color: AppColors.warning),
            const SizedBox(height: 16),
            Text('Pengumuman #$id',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Coming in Bagian 9', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
