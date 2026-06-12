// lib/shared/widgets/app_badge.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.filled = false,
  });

  factory AppBadge.category(String category) => AppBadge(
        label: _categoryLabel(category),
        color: AppColors.categoryColor(category),
      );

  factory AppBadge.priority(String priority) => AppBadge(
        label: _priorityLabel(priority),
        color: AppColors.priorityColor(priority),
        filled: priority == 'critical',
      );

  factory AppBadge.status(String status) => AppBadge(
        label: _statusLabel(status),
        color: _statusColor(status),
      );

  static String _categoryLabel(String c) {
    const map = {
      'lecture': 'Kuliah',
      'kuliah': 'Kuliah',
      'practicum': 'Praktikum',
      'praktikum': 'Praktikum',
      'seminar': 'Seminar',
      'organization': 'Organisasi',
      'organisasi': 'Organisasi',
      'task': 'Tugas',
      'tugas': 'Tugas',
      'exam': 'Ujian',
      'ujian': 'Ujian',
    };
    return map[c.toLowerCase()] ?? c;
  }

  static String _priorityLabel(String p) {
    const map = {
      'low': 'Rendah',
      'medium': 'Sedang',
      'high': 'Tinggi',
      'critical': 'Kritis',
    };
    return map[p.toLowerCase()] ?? p;
  }

  static String _statusLabel(String s) {
    const map = {
      'pending': 'Tertunda',
      'in_progress': 'Proses',
      'completed': 'Selesai',
      'overdue': 'Terlambat',
      'active': 'Aktif',
      'inactive': 'Nonaktif',
    };
    return map[s.toLowerCase()] ?? s;
  }

  static Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      case 'overdue':
        return AppColors.danger;
      case 'pending':
        return AppColors.textMuted;
      case 'active':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: filled ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
