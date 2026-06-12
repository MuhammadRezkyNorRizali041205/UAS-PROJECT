import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../data/models/gamification_model.dart';
import '../providers/gamification_provider.dart';

class DailyQuestScreen extends ConsumerWidget {
  const DailyQuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(dailyQuestsProvider);
    final profileAsync = ref.watch(gamificationProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Quest')),
      body: questsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
              const SizedBox(height: 12),
              Text(e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(dailyQuestsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (quests) => CustomScrollView(
          slivers: [
            // ── Header summary ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: profileAsync.when(
                  data: (p) => _QuestSummaryCard(
                    completed: p.todayQuestsCompleted,
                    total: p.todayQuestsTotal,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── Quest list ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.separated(
                itemCount: quests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _QuestCard(quest: quests[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary header ───────────────────────────────────────────────────────────

class _QuestSummaryCard extends StatelessWidget {
  final int completed;
  final int total;

  const _QuestSummaryCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quest Hari Ini',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text('$completed / $total Selesai',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completed == total && total > 0
                ? '🎉 Semua quest selesai!'
                : 'Selesaikan quest untuk mendapat poin bonus',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Quest card ───────────────────────────────────────────────────────────────

class _QuestCard extends StatelessWidget {
  final QuestModel quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: quest.isCompleted
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: quest.isCompleted ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: quest.isCompleted
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(quest.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    color: quest.isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: quest.isCompleted
                        ? TextDecoration.none
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quest.description,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                if (quest.targetCount > 1) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: quest.progressFraction,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${quest.progress} / ${quest.targetCount}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Reward + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (quest.isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('✓ Selesai',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+${quest.pointsReward} pts',
                      style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
