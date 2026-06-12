// lib/shared/widgets/app_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    Color bgColor;
    Color fgColor;
    Color borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = disabled
            ? AppColors.primary.withValues(alpha: 0.4)
            : AppColors.primary;
        fgColor = Colors.white;
        borderColor = Colors.transparent;
      case AppButtonVariant.secondary:
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        fgColor = AppColors.primary;
        borderColor = AppColors.primary.withValues(alpha: 0.3);
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = AppColors.textSecondary;
        borderColor = AppColors.border;
      case AppButtonVariant.danger:
        bgColor = disabled
            ? AppColors.danger.withValues(alpha: 0.4)
            : AppColors.danger.withValues(alpha: 0.15);
        fgColor = AppColors.danger;
        borderColor = AppColors.danger.withValues(alpha: 0.3);
    }

    final content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: fgColor),
              ),
            ],
          );

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height ?? 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: content,
          )),
        ),
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
