// lib/features/feed/presentation/screens/social_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/feed_providers.dart';
import '../../domain/entities/feed_post.dart';

class SocialFeedScreen extends ConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Pencapaian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePostDialog(context, ref),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada pencapaian dibagikan',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(feedProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: posts.length + 1,
              itemBuilder: (context, i) {
                if (i == posts.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () =>
                          ref.read(feedProvider.notifier).loadMore(),
                      child: const Text('Muat lebih banyak'),
                    ),
                  );
                }
                return _FeedCard(
                  post: posts[i],
                  onLike: () => ref
                      .read(feedProvider.notifier)
                      .toggleLike(posts[i].id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    String type     = 'task_completed';
    String vis      = 'public';

    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Bagikan Pencapaian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tipe'),
                  child: DropdownButton<String>(
                    value: type,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'task_completed',   child: Text('✅ Tugas selesai')),
                      DropdownMenuItem(value: 'streak_milestone', child: Text('🔥 Streak')),
                      DropdownMenuItem(value: 'badge_earned',     child: Text('🏅 Badge')),
                      DropdownMenuItem(value: 'level_up',         child: Text('⬆️ Level naik')),
                    ],
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Judul', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Deskripsi', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Visibilitas'),
                  child: DropdownButton<String>(
                    value: vis,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'public',  child: Text('🌐 Publik')),
                      DropdownMenuItem(value: 'friends', child: Text('👥 Teman')),
                    ],
                    onChanged: (v) => setState(() => vis = v!),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await ref.read(feedProvider.notifier).createPost(
                      type:        type,
                      title:       titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      visibility:  vis,
                    );
              },
              child: const Text('Bagikan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.post, required this.onLike});

  final FeedPost post;
  final VoidCallback onLike;

  static const _typeEmoji = {
    'task_completed':   '✅',
    'streak_milestone': '🔥',
    'badge_earned':     '🏅',
    'level_up':         '⬆️',
  };

  static const _typeColors = {
    'task_completed':   Color(0xFF4CAF50),
    'streak_milestone': Color(0xFFFF9800),
    'badge_earned':     Color(0xFF9C27B0),
    'level_up':         Color(0xFF2196F3),
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _typeEmoji[post.type] ?? '🏆';
    final color = _typeColors[post.type] ?? const Color(0xFF4CAF50);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(emoji),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeago.format(post.createdAt, locale: 'id'),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (post.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(post.description,
                  style: const TextStyle(color: Colors.black87)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post.isLiked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
