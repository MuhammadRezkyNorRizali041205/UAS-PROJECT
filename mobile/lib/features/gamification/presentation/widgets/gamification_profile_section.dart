import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../data/models/gamification_model.dart';
import '../providers/gamification_provider.dart';

/// Drop this widget anywhere in the profile screen to add gamification section.
/// It loads its own data independently — zero coupling with profile state.
class GamificationProfileSection extends ConsumerWidget {
  const GamificationProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(gamificationProfileProvider);

    return profileAsync.when(
      loading: () => const _SectionSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) => _GamificationContent(data: data),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _GamificationContent extends StatelessWidget {
  final GamificationProfileModel data;

  const _GamificationContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section title ───────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Gamifikasi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ── Level card ──────────────────────────────────────────────
          _LevelCard(data: data),
          const SizedBox(height: 12),

          // ── Stats row ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                  child: _StatCard(
                icon: '🔥',
                label: 'Streak',
                value: '${data.streak.current} hari',
                onTap: () {},
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                icon: '⭐',
                label: 'Quest Hari Ini',
                value:
                    '${data.todayQuestsCompleted}/${data.todayQuestsTotal}',
                onTap: () => context.push('/profile/gamification/quests'),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                icon: '🏆',
                label: 'Badge',
                value: '${data.recentAchievements.length}',
                onTap: () =>
                    context.push('/profile/gamification/achievements'),
              )),
            ],
          ),
          const SizedBox(height: 12),

          // ── Recent achievements ──────────────────────────────────────
          if (data.recentAchievements.isNotEmpty)
            _RecentAchievements(achievements: data.recentAchievements),
          const SizedBox(height: 12),

          // ── Action buttons ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: '🎯 Lihat Quest',
                  onTap: () =>
                      context.push('/profile/gamification/quests'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: '🏅 Leaderboard',
                  onTap: () =>
                      context.push('/profile/gamification/leaderboard'),
                ),
              ),
            ],
          ),
        ],
    );
  }
}

// ─── Level card ───────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final GamificationProfileModel data;
  const _LevelCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            data.levelColorValue.withValues(alpha: 0.3),
            data.levelColorValue.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: data.levelColorValue.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data.levelColorValue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: data.levelColorValue.withValues(alpha: 0.5)),
                ),
                child: Text(
                  data.levelLabel,
                  style: TextStyle(
                    color: data.levelColorValue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              // Points
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${data.totalPoints} pts',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Rank #${data.rank}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data.currentLevelPoints} pts',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                  Text(
                    data.nextLevelThreshold < 2147483647
                        ? '${data.nextLevelThreshold} pts'
                        : 'Max Level',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: data.progressPercentage / 100,
                  backgroundColor:
                      AppColors.surfaceElevated,
                  valueColor:
                      AlwaysStoppedAnimation(data.levelColorValue),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ─── Recent achievements ──────────────────────────────────────────────────────

class _RecentAchievements extends StatelessWidget {
  final List<AchievementModel> achievements;
  const _RecentAchievements({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Text('Badge Terbaru',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: achievements
                  .take(5)
                  .map((a) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Tooltip(
                          message: a.title,
                          child: Text(a.icon,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
