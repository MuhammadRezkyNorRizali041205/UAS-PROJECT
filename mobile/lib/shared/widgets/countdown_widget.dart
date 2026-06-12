// lib/shared/widgets/countdown_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CountdownWidget extends StatefulWidget {
  final DateTime deadline;
  final TextStyle? style;
  final bool compact;

  const CountdownWidget({
    super.key,
    required this.deadline,
    this.style,
    this.compact = false,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  _CountdownState _computeState() {
    final now = DateTime.now();
    final diff = widget.deadline.difference(now);

    if (diff.isNegative) {
      final overdue = now.difference(widget.deadline);
      return _CountdownState(
        text: _formatOverdue(overdue),
        color: AppColors.danger,
        isOverdue: true,
        isPulse: false,
        isStrike: true,
      );
    }

    if (diff.inMinutes < 30) {
      return _CountdownState(
        text: '${diff.inMinutes} menit lagi',
        color: AppColors.danger,
        isOverdue: false,
        isPulse: true,
        isStrike: false,
      );
    }

    if (diff.inHours < 3) {
      final h = diff.inHours;
      final m = diff.inMinutes.remainder(60);
      return _CountdownState(
        text: h > 0 ? '${h}j ${m}m lagi' : '${m}m lagi',
        color: AppColors.danger,
        isOverdue: false,
        isPulse: false,
        isStrike: false,
      );
    }

    if (diff.inHours < 48) {
      final h = diff.inHours;
      final m = diff.inMinutes.remainder(60);
      return _CountdownState(
        text: '${h}j ${m}m lagi',
        color: AppColors.warning,
        isOverdue: false,
        isPulse: false,
        isStrike: false,
      );
    }

    final d = diff.inDays;
    final h = diff.inHours.remainder(24);
    return _CountdownState(
      text: '${d}h ${h}j lagi',
      color: AppColors.textPrimary,
      isOverdue: false,
      isPulse: false,
      isStrike: false,
    );
  }

  String _formatOverdue(Duration d) {
    if (d.inDays > 0) return 'Terlambat ${d.inDays}h';
    if (d.inHours > 0) return 'Terlambat ${d.inHours}j';
    return 'Terlambat ${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final state = _computeState();
    final baseStyle = widget.style ??
        (widget.compact ? AppTextStyles.labelMedium : AppTextStyles.labelLarge);
    final textStyle = baseStyle.copyWith(
      color: state.color,
      decoration: state.isStrike ? TextDecoration.lineThrough : null,
      decorationColor: state.color,
    );

    Widget text = Text(
      state.text,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (state.isPulse) {
      text = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, child) =>
            Opacity(opacity: _pulseAnimation.value, child: child),
        child: text,
      );
    }

    if (widget.compact) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          state.isOverdue
              ? Icons.warning_rounded
              : Icons.schedule_rounded,
          size: 14,
          color: state.color,
        ),
        const SizedBox(width: 4),
        text,
      ],
    );
  }
}

class _CountdownState {
  final String text;
  final Color color;
  final bool isOverdue;
  final bool isPulse;
  final bool isStrike;

  const _CountdownState({
    required this.text,
    required this.color,
    required this.isOverdue,
    required this.isPulse,
    required this.isStrike,
  });
}
