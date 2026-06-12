import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../data/models/gamification_model.dart';
import '../providers/gamification_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const _scopes = [
    ('campus', '🌐 Kampus'),
    ('faculty', '🏫 Fakultas'),
    ('major', '📚 Prodi'),
    ('class', '👥 Kelas'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final notifier = ref.read(leaderboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Column(
        children: [
          // ── Scope selector ────────────────────────────────────────────
          _ScopeSelector(
            currentScope: notifier.currentScope,
            scopes: _scopes,
            onChanged: notifier.changeScope,
          ),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: leaderboardAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(e.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(leaderboardProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (data) => _LeaderboardContent(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scope selector ───────────────────────────────────────────────────────────

class _ScopeSelector extends StatelessWidget {
  final String currentScope;
  final List<(String, String)> scopes;
  final void Function(String) onChanged;

  const _ScopeSelector({
    required this.currentScope,
    required this.scopes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: scopes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label) = scopes[i];
          final selected = key == currentScope;
          return GestureDetector(
            onTap: () => onChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Leaderboard content ──────────────────────────────────────────────────────

class _LeaderboardContent extends StatelessWidget {
  final LeaderboardModel data;

  const _LeaderboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final top3 = data.entries.take(3).toList();
    final rest = data.entries.skip(3).toList();

    return CustomScrollView(
      slivers: [
        // ── Podium top 3 ─────────────────────────────────────────────
        if (top3.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: _Podium(top3: top3),
            ),
          ),

        // ── My rank (sticky-ish) ──────────────────────────────────────
        if (data.myRank != null && !(data.myRank!.rank <= 3))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _MyRankBanner(myRank: data.myRank!),
            ),
          ),

        // ── Rank 4+ ───────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.separated(
            itemCount: rest.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _RankRow(entry: rest[i]),
          ),
        ),
      ],
    );
  }
}

// ─── Podium ───────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<LeaderboardEntryModel> top3;
  const _Podium({required this.top3});

  @override
  Widget build(BuildContext context) {
    // Layout: 2nd | 1st | 3rd
    final order = [
      if (top3.length > 1) top3[1],
      top3[0],
      if (top3.length > 2) top3[2],
    ];

    final heights = top3.length > 1
        ? [top3.length > 2 ? 80.0 : 80.0, 110.0, 60.0]
        : [110.0];
    final medals = ['🥈', '🥇', '🥉'];
    final colors = [
      const Color(0xFFC0C0C0),
      const Color(0xFFFFD700),
      const Color(0xFFCD7F32),
    ];

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(order.length, (i) {
          final entry = order[i];
          final height = heights[i];
          final medal = medals[i];
          final color = colors[i];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Avatar(url: entry.avatarUrl, size: i == 1 ? 54 : 44),
                  const SizedBox(height: 4),
                  Text(entry.name.split(' ').first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  Text('${entry.totalPoints} pts',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      border: Border.all(
                          color: color.withValues(alpha: 0.5), width: 1.5),
                    ),
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(medal, style: const TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── My rank banner ───────────────────────────────────────────────────────────

class _MyRankBanner extends StatelessWidget {
  final LeaderboardEntryModel myRank;
  const _MyRankBanner({required this.myRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text('📍 Posisimu',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const Spacer(),
          Text('Rank #${myRank.rank}',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(width: 12),
          Text('${myRank.totalPoints} pts',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Rank row ─────────────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  final LeaderboardEntryModel entry;
  const _RankRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: entry.isCurrentUser
                    ? AppColors.primary
                    : AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Avatar(url: entry.avatarUrl, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isCurrentUser ? '${entry.name} (kamu)' : entry.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: entry.isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(entry.levelLabel,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${entry.totalPoints} pts',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  const _Avatar({this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.surfaceElevated,
      backgroundImage:
          url != null ? CachedNetworkImageProvider(url!) : null,
      child: url == null
          ? Icon(Icons.person, size: size * 0.5, color: AppColors.textMuted)
          : null,
    );
  }
}
