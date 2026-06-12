// lib/features/chat/presentation/screens/conversation_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/chat_providers.dart';

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(conversationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/chat/new'),
          ),
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => context.push('/chat/new-group'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (convs) {
          if (convs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada percakapan',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Cari teman untuk mulai chat',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(conversationListProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: convs.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final conv     = convs[i];
                final lastMsg  = conv.lastMessage;
                final initials = conv.name.isNotEmpty
                    ? conv.name.substring(0, 1).toUpperCase()
                    : '?';

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: conv.isGroup
                            ? Colors.blue.shade100
                            : Colors.purple.shade100,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: conv.isGroup
                                ? Colors.blue.shade700
                                : Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${conv.unreadCount > 99 ? '99+' : conv.unreadCount}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    conv.name,
                    style: TextStyle(
                      fontWeight: conv.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: lastMsg != null
                      ? Text(
                          lastMsg.isAchievement
                              ? '🏆 Achievement shared'
                              : lastMsg.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: conv.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        )
                      : const Text('Belum ada pesan',
                          style: TextStyle(color: Colors.grey)),
                  trailing: conv.lastMessageAt != null
                      ? Text(
                          timeago.format(conv.lastMessageAt!, locale: 'id'),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        )
                      : null,
                  onTap: () => context.push('/chat/${conv.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
