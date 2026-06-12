// lib/features/feed/presentation/widgets/like_button.dart

import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.onTap,
  });

  final bool isLiked;
  final int likesCount;
  final VoidCallback onTap;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(widget.isLiked),
                  color: widget.isLiked ? Colors.red : Colors.grey,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '${widget.likesCount}',
                key: ValueKey(widget.likesCount),
                style: TextStyle(
                  color: widget.isLiked ? Colors.red : Colors.grey,
                  fontWeight: widget.isLiked
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
