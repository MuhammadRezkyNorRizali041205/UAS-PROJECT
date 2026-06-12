// lib/shared/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Core ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color border = Color(0xFF2E2E2E);

  // ─── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // ─── Status ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // ─── Category ─────────────────────────────────────────────────────────
  static const Color categoryLecture = Color(0xFF6366F1);
  static const Color categoryPracticum = Color(0xFF8B5CF6);
  static const Color categorySeminar = Color(0xFF06B6D4);
  static const Color categoryOrganization = Color(0xFFF59E0B);
  static const Color categoryTask = Color(0xFF10B981);
  static const Color categoryExam = Color(0xFFEF4444);

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'lecture':
      case 'kuliah':
        return categoryLecture;
      case 'practicum':
      case 'praktikum':
        return categoryPracticum;
      case 'seminar':
        return categorySeminar;
      case 'organization':
      case 'organisasi':
        return categoryOrganization;
      case 'task':
      case 'tugas':
        return categoryTask;
      case 'exam':
      case 'ujian':
        return categoryExam;
      default:
        return primary;
    }
  }

  // ─── Priority ─────────────────────────────────────────────────────────
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFF6366F1);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityCritical = Color(0xFFEF4444);

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
      case 'rendah':
        return priorityLow;
      case 'medium':
      case 'sedang':
        return priorityMedium;
      case 'high':
      case 'tinggi':
        return priorityHigh;
      case 'critical':
      case 'kritis':
        return priorityCritical;
      default:
        return priorityMedium;
    }
  }
}
