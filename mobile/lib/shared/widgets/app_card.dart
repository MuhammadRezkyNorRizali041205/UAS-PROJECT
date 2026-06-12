// lib/shared/widgets/app_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final Border? border;
  final bool hoverable;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 16,
    this.border,
    this.hoverable = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? AppColors.surface;
    final effectiveColor =
        _hovered && widget.hoverable ? AppColors.surfaceElevated : baseColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border ??
            Border.all(
              color: _hovered && widget.hoverable
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: widget.hoverable ? (v) => setState(() => _hovered = v) : null,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Padding(
            padding:
                widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
