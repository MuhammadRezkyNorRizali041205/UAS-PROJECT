// path: lib/features/profile/presentation/widgets/profile_stat_item_widget.dart
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class ProfileStatItemWidget extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatItemWidget({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
