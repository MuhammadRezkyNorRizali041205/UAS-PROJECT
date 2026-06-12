// lib/features/chat/presentation/widgets/achievement_bubble.dart

import 'package:flutter/material.dart';

class AchievementBubble extends StatelessWidget {
  const AchievementBubble({
    super.key,
    required this.data,
    required this.isMine,
  });

  final Map<String, dynamic> data;
  final bool isMine;

  static const _typeColors = {
    'task_completed':   Color(0xFF4CAF50),
    'streak_milestone': Color(0xFFFF9800),
    'badge_earned':     Color(0xFF9C27B0),
    'level_up':         Color(0xFF2196F3),
  };

  static const _typeIcons = {
    'task_completed':   '✅',
    'streak_milestone': '🔥',
    'badge_earned':     '🏅',
    'level_up':         '⬆️',
  };

  @override
  Widget build(BuildContext context) {
    final type   = data['type'] as String? ?? 'task_completed';
    final title  = data['title'] as String? ?? 'Achievement';
    final desc   = data['description'] as String?;
    final points = data['points'] as int?;
    final color  = _typeColors[type] ?? const Color(0xFF4CAF50);
    final icon   = _typeIcons[type] ?? '🏆';

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (desc != null && desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
          if (points != null) ...[
            const SizedBox(height: 4),
            Text(
              '+$points XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
